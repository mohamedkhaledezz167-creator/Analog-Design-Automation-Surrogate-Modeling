clc; clear; close all;

load inverse_dnn_model.mat 

spec = [27, log10(5e6)];
spec_n = (spec - Ymu) ./ Ysigma;

x_n = predict(net_inv, spec_n);

x = x_n .* Xsigma + Xmu;

Rd = 10^x(1);
Wn = 10^x(2);
VG = x(3);
Ln = 10^x(4);

fprintf('Rd_from_inv_DNN= %.2f V/V\n',Rd);
fprintf('Wn_from_inv_DNN   = %.2e Hz\n', Wn);
fprintf('VG_from_inv_DNN  = %.2e V\n', VG);
fprintf('Ln_from_inv_DNN   = %.2e Hz\n', Ln);

[GAIN, BW] =  run_ltspice_common_source(Rd,Wn,VG,Ln);

fprintf('GAIN_after_design= %.2f V/V\n', GAIN);
fprintf('BW_after_design   = %.2e Hz\n', BW);

