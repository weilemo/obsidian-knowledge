"""
Reference implementation of Ada-KV budget allocation and two integrations:
- Ada-SnapKV
- Ada-Pyramid

This file is intentionally minimal and framework-agnostic (NumPy only).
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import List, Sequence, Tuple
import numpy as np


@dataclass
class AdaKVConfig:
    total_budget: int
    alpha: float = 0.2  # safeguard interpolation with uniform budget
    min_budget_per_head: int = 1


def _round_and_fix_sum(x: np.ndarray, target_sum: int) -> np.ndarray:
    """Round a float vector to int while preserving exact sum."""
    floored = np.floor(x).astype(np.int64)
    remain = int(target_sum - floored.sum())
    if remain > 0:
        frac = x - np.floor(x)
        idx = np.argsort(-frac)[:remain]
        floored[idx] += 1
    elif remain < 0:
        frac = x - np.floor(x)
        idx = np.argsort(frac)[: -remain]
        floored[idx] -= 1
    return floored


def allocate_budgets_global_topb(
    scores: np.ndarray,
    cfg: AdaKVConfig,
) -> np.ndarray:
    """
    Ada-KV core step.

    Args:
        scores: [H, N] non-negative importance scores per head-token.
        cfg: AdaKVConfig.

    Returns:
        budgets: [H] integer per-head budgets, sum == total_budget.

    Logic:
      1) Global Top-B over all head-token pairs.
      2) Count selected items per head -> raw head budgets f_i.
      3) Safeguard interpolation with uniform allocation:
           b_i <- (1-alpha)*f_i + alpha*(B/H)
      4) Enforce min budget and exact budget sum.
    """
    assert scores.ndim == 2, "scores must be [H, N]"
    H, N = scores.shape
    B = int(cfg.total_budget)
    if B <= 0:
        raise ValueError("total_budget must be positive")

    # If B is too small, allow zero per head by overriding min budget.
    min_b = int(cfg.min_budget_per_head)
    if H * min_b > B:
        min_b = 0

    flat = scores.reshape(-1)
    top_idx = np.argpartition(flat, -B)[-B:]
    head_ids = top_idx // N

    raw = np.bincount(head_ids, minlength=H).astype(np.float64)  # f_i

    # Safeguard: interpolate with uniform
    uniform = B / float(H)
    mixed = (1.0 - cfg.alpha) * raw + cfg.alpha * uniform

    # Enforce lower bound by shifting remaining budget
    mixed = np.maximum(mixed, min_b)

    # If lower bound caused overflow, project back with simple scaling on surplus part.
    if mixed.sum() > B:
        base = np.full(H, min_b, dtype=np.float64)
        free = mixed - base
        free_sum = free.sum()
        if free_sum > 1e-9:
            free *= max(0.0, (B - H * min_b) / free_sum)
        mixed = base + free

    budgets = _round_and_fix_sum(mixed, B)

    # Final safety pass
    if min_b > 0:
        deficits = np.where(budgets < min_b)[0]
        for d in deficits:
            need = min_b - budgets[d]
            donors = np.where(budgets > min_b)[0]
            for s in donors:
                if need == 0:
                    break
                take = min(need, budgets[s] - min_b)
                budgets[s] -= take
                budgets[d] += take
                need -= take

    assert budgets.sum() == B
    return budgets


def select_topk_per_head(scores: np.ndarray, budgets: np.ndarray) -> List[np.ndarray]:
    """Return kept token indices for each head."""
    H, N = scores.shape
    assert budgets.shape == (H,)
    keeps: List[np.ndarray] = []
    for h in range(H):
        k = int(budgets[h])
        if k <= 0:
            keeps.append(np.empty((0,), dtype=np.int64))
            continue
        idx = np.argpartition(scores[h], -k)[-k:]
        keeps.append(np.sort(idx))
    return keeps


def ada_snapkv(
    vote_scores: np.ndarray,
    obs_indices: np.ndarray,
    cfg: AdaKVConfig,
) -> Tuple[np.ndarray, List[np.ndarray], List[np.ndarray]]:
    """
    Ada-SnapKV integration.

    Args:
        vote_scores: [H, L_prefix], per-head prefix vote scores C_h(j).
        obs_indices: [L_obs], all observation-window token indices (always kept).
        cfg: budget for PREFIX part only.

    Returns:
        budgets: [H] prefix budgets per head.
        prefix_keep: list of per-head kept prefix indices.
        final_keep: list of per-head final kept indices = prefix_keep[h] U obs_indices.
    """
    budgets = allocate_budgets_global_topb(vote_scores, cfg)
    prefix_keep = select_topk_per_head(vote_scores, budgets)

    obs_sorted = np.unique(obs_indices)
    final_keep: List[np.ndarray] = []
    for h in range(vote_scores.shape[0]):
        final_keep.append(np.unique(np.concatenate([prefix_keep[h], obs_sorted])))
    return budgets, prefix_keep, final_keep


def ada_pyramid(
    layer_head_scores: np.ndarray,
    layer_total_budgets: Sequence[int],
    alpha: float = 0.2,
    min_budget_per_head: int = 1,
) -> Tuple[np.ndarray, List[List[np.ndarray]]]:
    """
    Ada-Pyramid integration.

    Args:
        layer_head_scores: [L, H, N], per-layer head-token importance scores.
        layer_total_budgets: length-L total budgets per layer.

    Returns:
        layer_budgets: [L, H] head budgets for each layer.
        layer_keeps: nested list, layer_keeps[l][h] are kept token indices.
    """
    assert layer_head_scores.ndim == 3
    L, H, N = layer_head_scores.shape
    if len(layer_total_budgets) != L:
        raise ValueError("layer_total_budgets length must match number of layers")

    layer_budgets = np.zeros((L, H), dtype=np.int64)
    layer_keeps: List[List[np.ndarray]] = []

    for l in range(L):
        cfg = AdaKVConfig(
            total_budget=int(layer_total_budgets[l]),
            alpha=alpha,
            min_budget_per_head=min_budget_per_head,
        )
        b = allocate_budgets_global_topb(layer_head_scores[l], cfg)
        k = select_topk_per_head(layer_head_scores[l], b)
        layer_budgets[l] = b
        layer_keeps.append(k)

    return layer_budgets, layer_keeps


def _demo() -> None:
    # 3 heads x 6 tokens example
    scores = np.array([
        [0.30, 0.25, 0.20, 0.10, 0.10, 0.05],
        [0.60, 0.15, 0.10, 0.07, 0.05, 0.03],
        [0.20, 0.18, 0.17, 0.16, 0.15, 0.14],
    ])
    cfg = AdaKVConfig(total_budget=6, alpha=0.2, min_budget_per_head=1)
    b = allocate_budgets_global_topb(scores, cfg)
    keep = select_topk_per_head(scores, b)
    print("budgets:", b.tolist())
    print("kept indices:", [x.tolist() for x in keep])


if __name__ == "__main__":
    _demo()
