% Problem 1: Compute DFT, magnitude and phase spectra
% ICE4405P DSP Lab 2

clear; clc; close all;

x = [1 2 3 4 3 2 1 0];
N = length(x);

% Direct DFT (definition with loops)
X = zeros(1, N);
for k = 0:N-1
    s = 0;
    for n = 0:N-1
        s = s + x(n+1) * exp(-1j*2*pi*k*n/N);
    end
    X(k+1) = s;
end

magX = abs(X);
phaX = angle(X);

disp('Problem 1: DFT coefficients X[k] =');
disp(X.');
disp('Magnitude |X[k]| =');
disp(magX.');
disp('Phase angle(X[k]) [rad] =');
disp(phaX.');

n = 0:N-1;
figure('Name','Problem 1');
subplot(3,1,1); stem(n, x, 'filled'); grid on;
xlabel('n'); ylabel('x[n]'); title('Original Signal');

subplot(3,1,2); stem(n, magX, 'filled'); grid on;
xlabel('k'); ylabel('|X[k]|'); title('Magnitude Spectrum');

subplot(3,1,3); stem(n, phaX, 'filled'); grid on;
xlabel('k'); ylabel('\angle X[k] (rad)'); title('Phase Spectrum');
