% Problem 3: Compare DFT and FFT computational performance
% ICE4405P DSP Lab 2

clear; clc; close all;

x = [1 2 3 4 3 2 1 0];
N = 1024;
x_long = [x zeros(1, N-length(x))];

% Direct DFT timing (nested loops)
X_dft = zeros(1, N);
tic;
for k = 0:N-1
    s = 0;
    for n = 0:N-1
        s = s + x_long(n+1) * exp(-1j*2*pi*k*n/N);
    end
    X_dft(k+1) = s;
end
t_dft = toc;

% FFT timing
tic;
X_fft = fft(x_long, N);
t_fft = toc;

fprintf('Problem 3 Timing (N=%d):\n', N);
fprintf('Direct DFT time: %.6f s\n', t_dft);
fprintf('FFT time      : %.6f s\n', t_fft);
fprintf('Speedup (DFT/FFT): %.2fx\n', t_dft / t_fft);

% Compare spectra
k = 0:N-1;
figure('Name','Problem 3');
subplot(2,1,1);
plot(k, abs(X_dft), 'LineWidth', 1.0); grid on;
xlabel('k'); ylabel('|X_{DFT}[k]|'); title('Magnitude Spectrum from Direct DFT');

subplot(2,1,2);
plot(k, abs(X_fft), 'LineWidth', 1.0); grid on;
xlabel('k'); ylabel('|X_{FFT}[k]|'); title('Magnitude Spectrum from FFT');
