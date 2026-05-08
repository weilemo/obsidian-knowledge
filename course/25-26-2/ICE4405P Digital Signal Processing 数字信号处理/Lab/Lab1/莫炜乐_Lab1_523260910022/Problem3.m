% Problem 3: DTFT Spectrum Analysis of a Speech Signal
% ICE4405P DSP Lab 1

clear;
clc;
close all;

% Signal definition: x[n] = 0.8^n, 0 <= n <= 10
n = 0:10;
x = 0.8.^n;

% Frequency grid over [-pi, pi]
Nw = 1024;
w = linspace(-pi, pi, Nw);

% Compute DTFT directly from definition
X = zeros(1, Nw);
for k = 1:Nw
    X(k) = sum(x .* exp(-1j * w(k) * n));
end

magX = abs(X);
phaseX = angle(X);

% Display a few key values
[~, idx0] = min(abs(w - 0));
[~, idxpi] = min(abs(w - pi));
[~, idxnpi] = min(abs(w + pi));

fprintf('Problem 3 Result\\n');
fprintf('|X(0)|      = %.6f\\n', magX(idx0));
fprintf('|X(pi)|     = %.6f\\n', magX(idxpi));
fprintf('|X(-pi)|    = %.6f\\n', magX(idxnpi));

% Plot magnitude and phase spectra
figure('Name', 'Problem 3 - DTFT of Speech Segment');

subplot(2,1,1);
plot(w, magX, 'LineWidth', 1.4);
grid on;
xlabel('\omega (rad/sample)');
ylabel('|X(\omega)|');
title('Magnitude Spectrum');

subplot(2,1,2);
plot(w, phaseX, 'LineWidth', 1.4);
grid on;
xlabel('\omega (rad/sample)');
ylabel('\angle X(\omega) (rad)');
title('Phase Spectrum');

