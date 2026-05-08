% Problem 4: High-Pass Filter for Speech Enhancement
% ICE4405P DSP Lab 1

clear;
clc;
close all;

% h[n] = (-0.5)^n u[n]
a = -0.5;

% Z-transform:
% H(z) = sum_{n=0}^{inf} (-0.5)^n z^{-n}
%      = 1 / (1 + 0.5 z^{-1})
% Pole at z = -0.5, ROC: |z| > 0.5
pole_location = -0.5;

% Stability check: for causal sequence ROC must include unit circle
is_stable = abs(pole_location) < 1;

% Frequency response to discuss high-pass behavior
w = linspace(0, pi, 1024);
H = 1 ./ (1 + 0.5 * exp(-1j * w));
magH = abs(H);

[~, idx0] = min(abs(w - 0));
[~, idxpi] = min(abs(w - pi));
gain_dc = magH(idx0);
gain_pi = magH(idxpi);

fprintf('Problem 4 Result\\n');
fprintf('H(z) = 1 / (1 + 0.5 z^{-1})\\n');
fprintf('Pole location: z = %.2f\\n', pole_location);
fprintf('ROC: |z| > 0.5\\n');
if is_stable
    fprintf('Stable? Yes\\n');
else
    fprintf('Stable? No\\n');
end
fprintf('|H(e^{j0})|   = %.6f\\n', gain_dc);
fprintf('|H(e^{jpi})|  = %.6f\\n', gain_pi);

if gain_pi > gain_dc
    fprintf('This filter amplifies high frequencies more than low frequencies (high-pass tendency).\\n');
    fprintf('It can help enhance speech clarity by reducing low-frequency components/noise.\\n');
end

% Plot magnitude response
figure('Name', 'Problem 4 - High-Pass Filter Analysis');
plot(w, magH, 'LineWidth', 1.4);
grid on;
xlabel('\omega (rad/sample)');
ylabel('|H(e^{j\omega})|');
title('Magnitude Response of H(z) = 1 / (1 + 0.5 z^{-1})');
