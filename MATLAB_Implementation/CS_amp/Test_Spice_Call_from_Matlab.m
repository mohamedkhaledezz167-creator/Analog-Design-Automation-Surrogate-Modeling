clc;
clear;

Rd = 30e3;        % 30k Ohm
Wn = 115.74e-6;   % 115.74 um
VG = 1.088;       % 1.088Volts
Ln = 4e-6;        %4 um

[GAIN, BW] =  run_ltspice_common_source(Rd,Wn,VG,Ln);

fprintf('GAIN= %.2f V/V\n', GAIN);
fprintf('BW   = %.2e Hz\n', BW);
