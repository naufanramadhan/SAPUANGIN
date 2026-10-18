function study = run_jsae_four_wheel_analysis(script_dir)
% Compatibility entry point for the original project name.
if nargin<1, script_dir=fileparts(mfilename('fullpath')); end
study=run_trackwidth_study(script_dir);
end
