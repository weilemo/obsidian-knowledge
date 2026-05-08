% Problem 4: Effect of zero-padding on spectral resolution
% ICE4405P DSP Lab 2

clear; clc; close all;

x = [1 2 3 4 3 2 1 0];
x_pad = [x zeros(1,8)];

X8 = fft(x, 8);
X16 = fft(x_pad, 16);

k8 = 0:7;
k16 = 0:15;

figure('Name','Problem 4');
subplot(2,1,1);
stem(k8, abs(X8), 'filled'); grid on;
xlabel('k'); ylabel('|X_8[k]|'); title('8-point Spectrum (No Extra Zero Padding)');

subplot(2,1,2);
stem(k16, abs(X16), 'filled'); grid on;
xlabel('k'); ylabel('|X_{16}[k]|'); title('16-point Spectrum (After Zero Padding)');
