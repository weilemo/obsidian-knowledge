# forcing_1 Claude Code 多 Provider 配置

## 核心结论

Claude Code 对第三方模型网关主要通过一组 `ANTHROPIC_*` 环境变量工作。百炼、DeepSeek 这类服务可以共存，但同一个 Claude Code 进程启动时只能读取一套当前环境变量。

所以要分两种情况：

- 单会话使用：可以切换 `/root/.claude/settings.json` 里的 provider。
- 多会话并行：不要反复改全局 settings，而是用 wrapper 在启动进程时临时注入环境变量。

## provider 配置文件

在 `forcing_1` 远端保留两份配置：

```bash
/root/.claude/providers/bailian.json
/root/.claude/providers/deepseek.json
```

百炼配置示例：

```json
{
  "ANTHROPIC_AUTH_TOKEN": "YOUR_BAILIAN_API_KEY_HERE",
  "ANTHROPIC_BASE_URL": "https://dashscope.aliyuncs.com/apps/anthropic",
  "ANTHROPIC_MODEL": "qwen3.7-max",
  "ANTHROPIC_DEFAULT_HAIKU_MODEL": "qwen3.6-flash",
  "ANTHROPIC_DEFAULT_SONNET_MODEL": "qwen3.7-max",
  "ANTHROPIC_DEFAULT_OPUS_MODEL": "qwen3.7-max",
  "CLAUDE_CODE_SUBAGENT_MODEL": "qwen3.7-max"
}
```

DeepSeek 配置示例：

```json
{
  "ANTHROPIC_AUTH_TOKEN": "YOUR_DEEPSEEK_OR_GATEWAY_API_KEY_HERE",
  "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
  "ANTHROPIC_MODEL": "deepseek-chat",
  "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-chat",
  "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-chat",
  "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-chat",
  "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-chat"
}
```

如果使用的是百炼 Token Plan 团队版专属 Key，百炼的 `ANTHROPIC_BASE_URL` 需要改成：

```text
https://token-plan.cn-beijing.maas.aliyuncs.com/apps/anthropic
```

不要把真实 API Key 写进公开笔记或聊天记录；如果不小心泄露，应在平台后台轮换。

## 填 API Key

如果已经在 `forcing_1` 远端 shell 里，不要再 `ssh forcing_1`，直接执行：

```bash
python3 - <<'PY'
from pathlib import Path
p = Path("/root/.claude/providers/bailian.json")
s = p.read_text()
s = s.replace("YOUR_BAILIAN_API_KEY_HERE", "你的百炼APIKey")
p.write_text(s)
PY
```

DeepSeek 同理：

```bash
python3 - <<'PY'
from pathlib import Path
p = Path("/root/.claude/providers/deepseek.json")
s = p.read_text()
s = s.replace("YOUR_DEEPSEEK_OR_GATEWAY_API_KEY_HERE", "你的DeepSeek或中转Key")
p.write_text(s)
PY
```

检查两边是否已经填好：

```bash
python3 - <<'PY'
import json
from pathlib import Path

for name in ["bailian", "deepseek"]:
    p = Path(f"/root/.claude/providers/{name}.json")
    token = json.loads(p.read_text()).get("ANTHROPIC_AUTH_TOKEN", "")
    ok = token.startswith("sk-") and "HERE" not in token
    print(name, "OK" if ok else "MISSING")
PY
```

## 单会话切换

远端有一个全局切换器：

```bash
/root/.local/bin/claude-provider
```

查看当前 provider：

```bash
/root/.local/bin/claude-provider status
```

切到百炼：

```bash
/root/.local/bin/claude-provider bailian
```

切到 DeepSeek：

```bash
/root/.local/bin/claude-provider deepseek
```

这种方式会改 `/root/.claude/settings.json`，适合只开一个 Claude Code 会话时使用。切完后需要重启 Claude Code 或新开会话。

## 两个 session 同时跑

如果要一个 Claude Code session 用百炼，另一个用 DeepSeek，使用 wrapper：

```bash
/root/.local/bin/claude-bailian
/root/.local/bin/claude-deepseek
```

它们会从对应 provider JSON 读取 API Key 和模型配置，只对当前启动的 Claude Code 进程生效，不互相覆盖。

两个 tmux session 示例：

```bash
tmux new -s cc-bailian
/root/.local/bin/claude-bailian
```

另一个终端：

```bash
tmux new -s cc-deepseek
/root/.local/bin/claude-deepseek
```

如果 shell 的 `PATH` 包含 `/root/.local/bin`，也可以直接：

```bash
claude-bailian
claude-deepseek
```

## 常见错误

如果已经在远端机器里，执行下面这种命令会报错：

```bash
ssh forcing_1 '...'
```

原因是 `forcing_1` 是本机 SSH 配置里的别名，远端机器自己不一定知道这个别名。已经在远端时，直接执行里面的命令即可。

如果看到：

```bash
bash: from: command not found
```

通常是因为复制 Python 脚本时漏掉了开头：

```bash
python3 - <<'PY'
```
