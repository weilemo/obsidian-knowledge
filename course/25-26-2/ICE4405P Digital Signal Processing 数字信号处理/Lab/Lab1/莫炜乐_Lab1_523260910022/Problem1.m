% Problem 1: Simulating a Recording Studio's Reverberation
% ICE4405P DSP Lab 1

clear;
clc;
close all;

% Impulse response of the studio
h = [1, 0.5, 0.3];

% Original drum sound
x = [2, 4, 6, 4, 2, 0];

% Convolution output (reverberated signal)
y = conv(x, h);

% Time indices for plotting
nx = 0:length(x)-1;
ny = 0:length(y)-1;

% Display numeric result
fprintf('Problem 1 Result\\n');
fprintf('y[n] = x[n] * h[n] =\\n');
disp(y);

% Plot original and reverberated signals
figure('Name', 'Problem 1 - Reverberation');

subplot(2,1,1);
stem(nx, x, 'filled', 'LineWidth', 1.2);
grid on;
xlabel('n');
ylabel('x[n]');
title('Original Drum Signal x[n]');

subplot(2,1,2);
stem(ny, y, 'filled', 'LineWidth', 1.2);
grid on;
xlabel('n');
ylabel('y[n]');
title('Reverberated Signal y[n] = x[n] * h[n]');

