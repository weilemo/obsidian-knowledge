% Problem 2: Zero even-indexed DFT coefficients and reconstruct
% ICE4405P DSP Lab 2

clear; clc; close all;

x = [1 2 3 4 3 2 1 0];
N = length(x);

% Compute DFT
X = fft(x, N);

% Set even-indexed k to zero: k = 0,2,4,6 -> MATLAB indices 1,3,5,7
X_mod = X;
X_mod(1:2:end) = 0;

% IDFT reconstruction
x_mod = real(ifft(X_mod, N));

disp('Problem 2: Modified DFT coefficients X_mod[k] =');
disp(X_mod.');
disp('Reconstructed signal x_mod[n] =');
disp(x_mod.');

n = 0:N-1;
figure('Name','Problem 2');
subplot(2,1,1);
stem(n, x, 'filled'); grid on;
xlabel('n'); ylabel('Amplitude'); title('Original Signal x[n]');

subplot(2,1,2);
stem(n, x_mod, 'filled'); grid on;
xlabel('n'); ylabel('Amplitude'); title('Reconstructed Signal after Zeroing Even-k Coefficients');
