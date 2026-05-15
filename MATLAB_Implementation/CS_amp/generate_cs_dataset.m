clc; clear;

%% ================= USER SETTINGS =================
N = 10000;                % Number of simulations

% Parameter ranges (PHYSICALLY MEANINGFUL)
Rd_min = 5e3;    Rd_max = 100e3;      % Ohms
Wn_min = 20e-6;  Wn_max = 300e-6;      % meters
VG_min = 0.8;    VG_max = 1.5;         % Volts
Ln_min = 0.18e-6; Ln_max = 2e-6;       % meters

%% ================= PRE-ALLOCATION =================
X = zeros(N,4);   % [Rd Wn VG Ln]
Y = zeros(N,2);   % [GAIN BW]

valid_count = 0;

%% ================= DATA GENERATION LOOP =================
for k = 1:N

    % ----- Sample input parameters -----
    Rd = Rd_min + (Rd_max - Rd_min)*rand;
    Wn = Wn_min + (Wn_max - Wn_min)*rand;
    VG = VG_min + (VG_max - VG_min)*rand;
    Ln = Ln_min + (Ln_max - Ln_min)*rand;

    try
        % ----- Run LTspice simulation -----
        [GAIN, BW] = run_ltspice_common_source(Rd, Wn, VG, Ln);

        % ----- Validate outputs -----
        if isnan(GAIN) || isnan(BW) || BW <= 0 || GAIN <= 0
            continue
        end

        % ----- Store results -----
        valid_count = valid_count + 1;
        X(valid_count,:) = [Rd, Wn, VG, Ln];
        Y(valid_count,:) = [GAIN, BW];

    catch
        % LTspice failure -> skip
        continue
    end

    % ----- Progress display -----
    if mod(k,500) == 0
        fprintf('Completed %d / %d simulations\n', k, N);
    end
end

%% ================= CLEAN DATA =================
X = X(1:valid_count,:);
Y = Y(1:valid_count,:);

fprintf('Valid simulations: %d / %d\n', valid_count, N);

%% ================= SAVE DATA =================
save('cs_datasets.mat','X','Y');

