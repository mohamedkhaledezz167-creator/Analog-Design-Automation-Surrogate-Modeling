clc; clear; close all;

load cs_dataset.mat   % loads X, Y

%% Log-transform
X_log = [ ...
    log10(X(:,1)), ...
    log10(X(:,2)), ...
    X(:,3), ...
    log10(X(:,4)) ...
];

Y_log = [ ...
    Y(:,1), ...
    log10(Y(:,2)) ...
];

%% Normalize
[Xn, Xmu, Xsigma] = zscore(X_log);
[Yn, Ymu, Ysigma] = zscore(Y_log);

%% Train/test split (same as NN)
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

%% Train regression models
mdl_gain = fitlm(Xtrain, Ytrain(:,1));
mdl_bw   = fitlm(Xtrain, Ytrain(:,2));

%% Predict
GAIN_pred_n = predict(mdl_gain, Xtest);
BW_pred_n   = predict(mdl_bw, Xtest);

%% De-normalize
GAIN_pred = GAIN_pred_n .* Ysigma(1) + Ymu(1);
BW_pred   = 10.^(BW_pred_n .* Ysigma(2) + Ymu(2));

GAIN_true = Y(test_idx,1);
BW_true   = Y(test_idx,2);

%% Errors
gain_rmse = sqrt(mean((GAIN_pred - GAIN_true).^2));
bw_relerr = mean(abs(BW_pred - BW_true) ./ BW_true);

fprintf('REGRESSION GAIN RMSE = %.3f\n', gain_rmse);
fprintf('REGRESSION BW REL ERR = %.2f %%\n', bw_relerr*100);
