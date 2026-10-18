% Track-width screening study. MATLAB R2019b+ or GNU Octave 9+.
% Edit baseline column E and 06_SIMULATION_CONFIG in the input workbook.
% Proposed column F is deliberately NOT read by this study.
clc;
script_dir = fileparts(mfilename('fullpath'));
addpath(script_dir);
study = run_trackwidth_study(script_dir);
