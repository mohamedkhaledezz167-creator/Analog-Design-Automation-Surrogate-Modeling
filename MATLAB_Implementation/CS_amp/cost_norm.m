function J = cost_norm(z, net_fwd, Yt_n)
% z    : normalized input/control variables (1x4) — MUST be double
% Yt_n : normalized target (1x2) — MUST be double

    % --- Force input to double row vector ---
    z = double(z(:).');    

    % --- Forward prediction ---
    Yp_n = predict(net_fwd, z);

    % --- CRITICAL FIX ---
    % Convert network output to plain double
    if isa(Yp_n, 'dlarray')
        Yp_n = extractdata(Yp_n);
    end

    Yp_n = double(Yp_n);

    % --- Error ---
    err = Yp_n - Yt_n;

    % --- Scalar double cost ---
    J = double(err(1)^2 + err(2)^2);
end
