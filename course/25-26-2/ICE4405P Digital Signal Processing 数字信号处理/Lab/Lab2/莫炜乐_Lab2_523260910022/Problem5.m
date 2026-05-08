% Problem 5: Low-pass filtering for noisy speech reconstruction
% ICE4405P DSP Lab 2

clear; clc; close all;

N = 256;
n = 0:N-1;
rng(2026); % reproducibility

x_clean = sin(0.2*pi*n) + 0.5*sin(0.7*pi*n);
x = x_clean + 0.2*randn(1, N);

% FFT of noisy signal
X = fft(x);

% Keep only lowest 10% frequency bins
X_lp = zeros(size(X));
keep = round(0.1*N);
X_lp(1:keep) = X(1:keep);

% For real-valued reconstruction, keep conjugate symmetry bins as well
X_lp(end-keep+2:end) = X(end-keep+2:end);

% IFFT reconstruction
y = real(ifft(X_lp));

fprintf('Problem 5: N = %d, kept bins = %d (plus symmetric bins)\n', N, keep);

% Plot time-domain comparison
figure('Name','Problem 5');
subplot(3,1,1);
plot(n, x_clean, 'LineWidth', 1.0); grid on;
xlabel('n'); ylabel('Amplitude'); title('Original Clean Signal');

subplot(3,1,2);
plot(n, x, 'LineWidth', 1.0); grid on;
xlabel('n'); ylabel('Amplitude'); title('Noisy Signal');

subplot(3,1,3);
plot(n, y, 'LineWidth', 1.0); grid on;
xlabel('n'); ylabel('Amplitude'); title('Reconstructed Signal After Low-pass Filtering');

% Plot magnitude spectrum of noisy and filtered signals
figure('Name','Problem 5 Spectrum');
f = 0:N-1;
plot(f, abs(X), 'b', 'LineWidth', 1.0); hold on;
plot(f, abs(X_lp), 'r', 'LineWidth', 1.0);
grid on;
xlabel('k'); ylabel('Magnitude');
legend('Noisy Spectrum', 'Low-pass Spectrum');
title('Problem 5: Spectrum Before and After Frequency-domain LPF');
