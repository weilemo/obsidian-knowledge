% Problem 5: Stability Analysis of a Low-Pass Filter
% ICE4405P DSP Lab 1

clear;
clc;
close all;

% h[n] = (0.7)^n u[n]
a = 0.7;

% Z-transform:
% H(z) = sum_{n=0}^{inf} (0.7)^n z^{-n}
%      = 1 / (1 - 0.7 z^{-1})
% Pole at z = 0.7, ROC: |z| > 0.7
pole_location = 0.7;
is_stable = abs(pole_location) < 1;

% Frequency response for comparison with Problem 4
w = linspace(0, pi, 1024);
H = 1 ./ (1 - 0.7 * exp(-1j * w));
magH = abs(H);

[~, idx0] = min(abs(w - 0));
[~, idxpi] = min(abs(w - pi));
gain_dc = magH(idx0);
gain_pi = magH(idxpi);

fprintf('Problem 5 Result\\n');
fprintf('H(z) = 1 / (1 - 0.7 z^{-1})\\n');
fprintf('Pole location: z = %.2f\\n', pole_location);
fprintf('ROC: |z| > 0.7\\n');
if is_stable
    fprintf('Stable? Yes\\n');
else
    fprintf('Stable? No\\n');
end
fprintf('|H(e^{j0})|   = %.6f\\n', gain_dc);
fprintf('|H(e^{jpi})|  = %.6f\\n', gain_pi);

if gain_dc > gain_pi
    fprintf('This filter emphasizes low frequencies more than high frequencies (low-pass behavior).\\n');
end

fprintf('Comparison with Problem 4: P4 tends to high-pass, while P5 tends to low-pass.\\n');

% Plot magnitude response
figure('Name', 'Problem 5 - Low-Pass Filter Analysis');
plot(w, magH, 'LineWidth', 1.4);
grid on;
xlabel('\omega (rad/sample)');
ylabel('|H(e^{j\omega})|');
title('Magnitude Response of H(z) = 1 / (1 - 0.7 z^{-1})');

