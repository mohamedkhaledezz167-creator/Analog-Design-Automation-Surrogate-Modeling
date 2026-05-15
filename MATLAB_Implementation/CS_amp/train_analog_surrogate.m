
%% Load data
load cs_dataset.mat   % loads X, Y

%% -----------------------------
% STEP 1: Log-transform (VERY IMPORTANT)
%% -----------------------------
X_log = [ ...
    log10(X(:,1)), ...   % Rd
    log10(X(:,2)), ...   % Wn
    X(:,3), ...          % VG
    log10(X(:,4)) ...    % Ln
];

Y_log = [ ...
    Y(:,1), ...          % Gain
    log10(Y(:,2)) ...    % BW
];

%% -----------------------------
% STEP 2: Normalize
%% -----------------------------
[Xn, Xmu, Xsigma] = zscore(X_log);
[Yn, Ymu, Ysigma] = zscore(Y_log);

%% -----------------------------
% STEP 3: Train / Test split
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
% STEP 4: Define DNN
%% -----------------------------
layers = [
    featureInputLayer(4)

    fullyConnectedLayer(64)
    reluLayer

    fullyConnectedLayer(64)
    reluLayer

    fullyConnectedLayer(32)
    reluLayer

    fullyConnectedLayer(2)
    regressionLayer
];

%% -----------------------------
% STEP 5: Training options
%% -----------------------------
options = trainingOptions('adam', ...
    'MaxEpochs', 500, ...
    'MiniBatchSize', 64, ...
    'InitialLearnRate', 1e-3, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', false, ...
    'Plots', 'training-progress');

%% -----------------------------
% STEP 6: Train network
%% -----------------------------
net = trainNetwork(Xtrain, Ytrain, layers, options);

%% -----------------------------
% STEP 7: Predict on test set
%% -----------------------------
Ypred_n = predict(net, Xtest);

%% -----------------------------
% STEP 8: De-normalize
%% -----------------------------
Ypred_log = Ypred_n .* Ysigma + Ymu;

GAIN_pred = Ypred_log(:,1);
BW_pred   = 10.^(Ypred_log(:,2));

GAIN_true = Y(test_idx,1);
BW_true   = Y(test_idx,2);

%% -----------------------------
% STEP 9: Error metrics
%% -----------------------------
gain_rmse = sqrt(mean((GAIN_pred - GAIN_true).^2));
bw_relerr = mean(abs(BW_pred - BW_true) ./ BW_true);

fprintf('GAIN RMSE = %.3f\n', gain_rmse);
fprintf('BW Mean Relative Error = %.2f %%\n', bw_relerr*100);

%% -----------------------------
% STEP 10: Plots (thesis-ready)
%% -----------------------------
figure;
scatter(GAIN_true, GAIN_pred, 'filled')
xlabel('SPICE Gain')
ylabel('NN Predicted Gain')
grid on
title('Gain Prediction')

figure;
scatter(BW_true, BW_pred, 'filled')
xlabel('SPICE Bandwidth (Hz)')
ylabel('NN Predicted Bandwidth (Hz)')
set(gca,'XScale','log','YScale','log')
grid on
title('Bandwidth Prediction')

save analog_surrogate.mat net Xmu Xsigma Ymu Ysigma

