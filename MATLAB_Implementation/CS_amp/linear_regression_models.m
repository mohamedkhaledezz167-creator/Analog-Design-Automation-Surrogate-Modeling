clc; clear; close all;

%% Load dataset
load cs_dataset.mat   % loads X, Y   % X = [Rd Wn VG Ln], Y = [GAIN BW]

results_dir = 'regression_results';
if ~exist(results_dir,'dir')
    mkdir(results_dir);
end

%% -----------------------------
% Log-transform
%% -----------------------------
X_log = [ ...
    log10(X(:,1)), ...   % Rd
    log10(X(:,2)), ...   % Wn
    X(:,3), ...          % VG (no log)
    log10(X(:,4)) ...    % Ln
];

Y_log = [ ...
    Y(:,1), ...          % Gain (linear)
    log10(Y(:,2)) ...    % BW (log)
];

%% -----------------------------
% Normalize
%% -----------------------------
[Xn, Xmu, Xsigma] = zscore(X_log);
[Yn, Ymu, Ysigma] = zscore(Y_log);

%% -----------------------------
% Train/Test split
%% -----------------------------
N = size(Xn,1);
rng(1);
idx = randperm(N);
Ntrain = round(0.8*N);

train_idx = idx(1:Ntrain);
test_idx  = idx(Ntrain+1:end);

Xtrain = Xn(train_idx,:);
Ytrain = Yn(train_idx,:);
Xtest  = Xn(test_idx,:);
Ytest  = Yn(test_idx,:);

%% -----------------------------
% Train regression models
%% -----------------------------
mdl_gain = fitlm(Xtrain, Ytrain(:,1));
mdl_bw   = fitlm(Xtrain, Ytrain(:,2));

%% -----------------------------
% Predict (normalized)
%% -----------------------------
GAIN_pred_n = predict(mdl_gain, Xtest);
BW_pred_n   = predict(mdl_bw, Xtest);

%% -----------------------------
% De-normalize
%% -----------------------------
GAIN_pred = GAIN_pred_n .* Ysigma(1) + Ymu(1);
BW_pred   = 10.^(BW_pred_n .* Ysigma(2) + Ymu(2));

GAIN_true = Y(test_idx,1);
BW_true   = Y(test_idx,2);

%% -----------------------------
% Errors
%% -----------------------------
gain_rmse = sqrt(mean((GAIN_pred - GAIN_true).^2));
bw_relerr = mean(abs(BW_pred - BW_true) ./ BW_true);

fprintf('REGRESSION GAIN RMSE = %.3f\n', gain_rmse);
fprintf('REGRESSION BW REL ERR = %.2f %%\n', bw_relerr*100);

%% =============================
% PLOTS
%% =============================

%  Gain: Predicted vs True
figure;
scatter(GAIN_true, GAIN_pred, 25, 'filled');
hold on;
plot([min(GAIN_true) max(GAIN_true)], ...
     [min(GAIN_true) max(GAIN_true)], 'r--', 'LineWidth', 1.5);
xlabel('True Gain');
ylabel('Predicted Gain');
title('Linear Regression: Gain Prediction');
grid on;
saveas(gcf, fullfile(results_dir,'gain_pred_vs_true.png'));

%  BW: Predicted vs True (log-log)
figure;
loglog(BW_true, BW_pred, 'bo');
hold on;
loglog([min(BW_true) max(BW_true)], ...
       [min(BW_true) max(BW_true)], 'r--', 'LineWidth', 1.5);
xlabel('True BW (Hz)');
ylabel('Predicted BW (Hz)');
title('Linear Regression: Bandwidth Prediction');
grid on;
saveas(gcf, fullfile(results_dir,'bw_pred_vs_true.png'));

% Gain error histogram
figure;
histogram(GAIN_pred - GAIN_true, 50);
xlabel('Gain Error');
ylabel('Count');
title('Gain Error Distribution');
grid on;
saveas(gcf, fullfile(results_dir,'gain_error_hist.png'));

% BW relative error histogram
figure;
histogram(100 * abs(BW_pred - BW_true) ./ BW_true, 50);
xlabel('BW Relative Error (%)');
ylabel('Count');
title('Bandwidth Relative Error Distribution');
grid on;
saveas(gcf, fullfile(results_dir,'bw_rel_error_hist.png'));

%% =============================
% SAVE MODELS
%% =============================
save linear_regression_models.mat ...
     mdl_gain mdl_bw ... 
     Xmu Xsigma Ymu Ysigma ;

save(fullfile(results_dir,'linear_regression_models.mat'), ...
     'mdl_gain','mdl_bw', ...
     'Xmu','Xsigma','Ymu','Ysigma');

disp('Regression results, plots, and models saved successfully.');
