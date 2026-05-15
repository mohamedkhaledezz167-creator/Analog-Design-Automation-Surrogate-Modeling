function [Gain, BW] = run_ltspice_common_source(Rd,Wn,VG,Ln)
% run_ltspice_cs
% Inputs:
%   Rd  - Drain resistance (Ohms)
%   Wn  - NMOS width (meters)
%   VG  - Gate bias voltage (Volts)
%   Ln  - NMOS Length (metres)
%
% Outputs:
%   Gain - Max small-signal gain (V/V)
%   BW   - Bandwidth (Hz)

%% === USER SETTINGS ===
ltspiceExe = ...
    '"C:\Users\Mohamed\AppData\Local\Programs\ADI\LTspice\LTspice.exe"';

netlistFile = 'cs_amp.sp';

%% === MODIFY NETLIST PARAMETERS ===
txt = fileread(netlistFile);

txt = regexprep(txt, ...
    '(\.param\s+Rd\s*=\s*)([^\r\n]+)', ...
    sprintf('$1%g', Rd));

txt = regexprep(txt, ...
    '(\.param\s+Wn\s*=\s*)([^\r\n]+)', ...
    sprintf('$1%g', Wn));

txt = regexprep(txt, ...
    '(\.param\s+VG\s*=\s*)([^\r\n]+)', ...
    sprintf('$1%g', VG));

txt = regexprep(txt, ...
    '(\.param\s+Ln\s*=\s*)([^\r\n]+)', ...
    sprintf('$1%g', Ln));


fid = fopen(netlistFile, 'w');
fwrite(fid, txt);
fclose(fid);


%% === RUN LTSPICE (BATCH MODE) ===
cmd = sprintf('%s -b "%s"', ltspiceExe, netlistFile);
status = system(cmd);

if status ~= 0
    error('LTspice simulation failed.');
end

%% === READ LOG FILE ===
logFile = strrep(netlistFile, '.sp', '.log');

if ~isfile(logFile)
    error('LTspice log file not found.');
end

% Read the entire log file content into a string
logText = fileread(logFile);

%% === PARSE GAIN ===
% Regex explanation: 
% (?<=MAX\(mag\(v\(out\)\)\)=\() - looks behind for the exact string before the number (the parenthesis needs an escape character)
% ([\d.eE+-]+) - captures the actual number (digits, period, e/E for scientific notation, +/- signs)
% (?=dB) - looks ahead for the "dB" string
gainToken = regexp(logText, ...
    '(?<=MAX\(mag\(v\(out\)\)\)\=\()([\d.eE+-]+)(?=dB)', 'tokens', 'ignorecase');

if isempty(gainToken)
    error('GAIN value not found in log file with the expected format.');
end
% The result is a cell array within a cell array, so we access it twice:
Gain_dB = str2double(gainToken{1}{1}); 

% Note: You are now getting the gain in dB. 
% If your function needs Gain in V/V (linear scale), you must convert it:
Gain = 10^(Gain_dB / 20); % Convert dB to linear scale (V/V)


%% === PARSE BANDWIDTH ===
% Regex explanation:
% (?<=AT\s+) - looks behind for the literal string "AT " (with a space)
% ([\d.eE+-]+) - captures the actual number (the frequency)
bwToken = regexp(logText, ...
    '(?<=AT\s+)([\d.eE+-]+)', 'tokens', 'ignorecase');

if isempty(bwToken)
    error('BW not found in log file with the expected format.');
end

% The result is a cell array within a cell array, so we access it twice:
BW = str2double(bwToken{1}{1}); % This is the bandwidth in Hz

end
