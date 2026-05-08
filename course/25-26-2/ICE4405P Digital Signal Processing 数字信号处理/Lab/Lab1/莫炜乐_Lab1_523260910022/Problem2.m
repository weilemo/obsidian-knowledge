% Problem 2: Simulating Echo in an Open Space
% ICE4405P DSP Lab 1

clear;
clc;
close all;

% Echo/reverberation impulse response
h = [1, 0.5, 0.3];

% Original signal x[n] = 0.8^n, 0 <= n <= 10
n = 0:10;
x = 0.8.^n;

% Echoed output
y = conv(x, h);
ny = 0:length(y)-1;

% Display numeric results
fprintf('Problem 2 Result\\n');
fprintf('x[n] = 0.8^n, n = 0..10\\n');
fprintf('y[n] = x[n] * h[n] =\\n');
disp(y);

% Plot original and echoed signals
figure('Name', 'Problem 2 - Echo Simulation');

subplot(2,1,1);
stem(n, x, 'filled', 'LineWidth', 1.2);
grid on;
xlabel('n');
ylabel('x[n]');
title('Original Signal x[n] = 0.8^n');

subplot(2,1,2);
stem(ny, y, 'filled', 'LineWidth', 1.2);
grid on;
xlabel('n');
ylabel('y[n]');
title('Echoed Signal y[n] = x[n] * h[n]');

