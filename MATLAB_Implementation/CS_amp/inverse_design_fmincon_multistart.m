clc; clear; close all;

%% =============================
% Load FORWARD DNN
%% =============================
load dnn_training_results.mat
% net, Xmu, Xsigma, Ymu, Ysigma

%% =============================
% Desired specs
%% =============================
GAIN_target = 27;
BW_target   = 5e6;

Yt_log = [GAIN_target, log10(BW_target)];
Yt_n   = (Yt_log - Ymu) ./ Ysigma;

%% =============================
% Bounds in PHYSICAL space
%% =============================
lb_phys = [ 10e3,   50e-6,  0.6,  3e-6 ];    % lower bound
ub_phys = [ 50e3,  200e-6, 1.5,  10e-6 ];        % upper bound

%% Convert bounds → normalized/log space
lb_log = [log10(lb_phys(1)), log10(lb_phys(2)), lb_phys(3), log10(lb_phys(4))];
ub_log = [log10(ub_phys(1)), log10(ub_phys(2)), ub_phys(3), log10(ub_phys(4))];

lb = (lb_log - Xmu) ./ Xsigma;
ub = (ub_log - Xmu) ./ Xsigma;

%% Initial guess (center of training space)
%x0 = [20e3,100e-6,1,4e-6];
%x_nlog_0 =[log10(x0(1)),log10(x0(2)),x0(3),log10(x0(4))];
%x_n0 = (x_nlog_0 - Xmu) ./ Xsigma;
x_n0=zeros(1,4);

%% =============================
% Optimization options
%% =============================
options = optimoptions('fmincon', ...
    'Algorithm','interior-point', ...
    'Display','iter', ...
    'MaxFunctionEvaluations',8000);

%% =============================
% Run optimization (NORMALIZED space)
%% =============================
% Define the objective function handle (same as before)
costHandle = @(x) cost_norm(x, net, Yt_n);

% 1. Create the base optimization problem structure
% Note: You need to define x0, lb, ub first. Assume they are defined.
problem = createOptimProblem('fmincon', ...
                             'objective', costHandle, ...
                             'x0', x_n0, ...
                             'lb', lb, ...
                             'ub', ub, ...
                             'options', options);

% 2. Create a MultiStart object
% 'ms' object will manage running the local solver from many points
ms = MultiStart;

% 3. Run the optimization with MultiStart, using N start points (e.g., 50)
% The 'run' function will handle the multiple fmincon calls and return the best x_opt
num_runs = 50; 
[x_opt, fval] = run(ms, problem, num_runs);
%% =============================
% Convert back to PHYSICAL values
%% =============================
x_log = x_opt .* Xsigma + Xmu;

Rd = 10^x_log(1);
Wn = 10^x_log(2);
VG = x_log(3);
Ln = 10^x_log(4);

fprintf('\nOptimized Design:\n');
fprintf('Rd = %.1f ohm\n', Rd);
fprintf('Wn = %.2f um\n', Wn*1e6);
fprintf('VG = %.3f V\n', VG);
fprintf('Ln = %.2f um\n', Ln*1e6);

%% =============================
% Verify prediction
%% =============================
y_n = predict(net, x_opt);
y_log = y_n .* Ysigma + Ymu;

fprintf('\nPredicted Performance:\n');
fprintf('Gain_after_design = %.2f\n', y_log(1));
fprintf('BW_after_Design  = %.2e Hz\n', 10^y_log(2));

[GAIN_true, BW_true] =  run_ltspice_common_source(Rd,Wn,VG,Ln);

fprintf('GAIN_true= %.2f V/V\n', GAIN_true);
fprintf('BW_true   = %.2e Hz\n', BW_true);
