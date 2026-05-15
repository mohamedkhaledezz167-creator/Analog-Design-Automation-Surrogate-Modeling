
clc; clear; close all;

load dnn_training_results.mat 

Rd = 30e3;        % 30k Ohm
Wn = 115.74e-6;   % 115.74 um
VG = 1.088;       % 1.088Volts
Ln = 4e-6;        %4 um


x_new = [Rd, Wn, VG, Ln];

x_log = [log10(x_new(1)), log10(x_new(2)), x_new(3), log10(x_new(4))];
x_n   = (x_log - Xmu) ./ Xsigma;

y_n = predict(net, x_n);
y   = y_n .* Ysigma + Ymu;

GAIN_est = y(1);
BW_est   = 10^(y(2));


[GAIN_true, BW_true] =  run_ltspice_common_source(Rd,Wn,VG,Ln);

fprintf('GAIN_true= %.2f V/V\n', GAIN_true);
fprintf('BW_true= %.2e Hz\n', BW_true);

fprintf('GAIN_est= %.2f V/V\n', GAIN_est);
fprintf('BW_est = %.2e Hz\n', BW_est);


