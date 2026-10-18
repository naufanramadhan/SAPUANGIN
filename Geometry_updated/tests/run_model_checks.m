function count = run_model_checks(root)
% Physical invariants, limiting cases, and failure behavior of the actual .m core.
if nargin<1, root=fileparts(fileparts(mfilename('fullpath'))); end
addpath(root);
[p,c]=read_study_inputs(root);
count=0; widths=[p.T_f,(p.T_f+c.front_track_max_mm)/2,c.front_track_max_mm];
free=calculate_four_wheel(p,widths,c,'fixed_wheel_rate');
held=calculate_four_wheel(p,widths,c,'fixed_axle_roll_stiffness');
count=count+check(all([free.T_r]==p.T_r),'Rear track stays fixed');
count=count+check(abs(free(1).Ay_capacity-held(1).Ay_capacity)<1e-12, ...
    'Two scenarios agree at measured baseline');
count=count+check(max(abs([held.K_phi_f]-held(1).K_phi_f))<1e-10, ...
    'Controlled scenario holds axle roll stiffness');
count=count+check(free(end).K_phi_f>free(1).K_phi_f, ...
    'Fixed wheel rate exposes added front roll stiffness');
for j=1:numel(free)
    car=free(j);
    state=four_wheel_state(p,car,[0,.5,1]);
    count=count+check(max(abs(sum(state.Fz_N,1)-p.W_total))<1e-9, ...
        sprintf('Vertical force conservation, case %d',j));
    roll_moment=car.transfer_per_g(1)*car.T_f/1000 + ...
        car.transfer_per_g(2)*car.T_r/1000;
    count=count+check(abs(roll_moment-p.m_total*p.g*p.h/1000)<1e-9, ...
        sprintf('Total lateral overturning moment, case %d',j));
    left=four_wheel_state(p,car,.8,1);
    right=four_wheel_state(p,car,.8,-1);
    count=count+check(max(abs(left.Fz_N-right.Fz_N([2 1 4 3])))<1e-9, ...
        sprintf('Left/right symmetry, case %d',j));
    state=four_wheel_state(p,car,car.Ay_capacity*.999);
    count=count+check(all(state.axle_utilisation<=1+1e-8) && ...
        all(state.Fz_N>=0),'Reported capacity meets BOTH axle demands');
    state=four_wheel_state(p,car,car.Ay_capacity*1.001);
    count=count+check(any(state.axle_utilisation>1) || any(state.Fz_N<0), ...
        'Capacity boundary actually limits the vehicle');
end
% Constant mu: front axle at mu=1.1 must limit, despite rear mu=1.5.
test=p; test.mu_0f=1.1; test.mu_0r=1.5;
test.dmu_dFz_f=0; test.dmu_dFz_r=0;
car=calculate_four_wheel(test,p.T_f,c,'fixed_wheel_rate');
count=count+check(abs(car.Ay_capacity-1.1)<1e-9 && ...
    strcmp(car.limiting_axle,'Front'),'Known front-limited constant-mu case');
test.mu_0f=1.5; test.mu_0r=1.1;
car=calculate_four_wheel(test,p.T_f,c,'fixed_wheel_rate');
count=count+check(abs(car.Ay_capacity-1.1)<1e-9 && ...
    strcmp(car.limiting_axle,'Rear'),'Known rear-limited constant-mu case');
car=free(1); cc=c; cc.skidpad_max_steer_deg=1;
skid=simulate_skidpad(car,p,cc);
count=count+check(~skid.steering_feasible && ~skid.screened && ...
    isinf(skid.lap_time_s),'Insufficient steering is infeasible, not zero-speed valid');
cc=c; cc.track_width_m=.5;
track=read_ac_ai_spline(fullfile(root,'input','track','fast_lane.ai'));
rawc=c; rawc.path_scale_mode='raw';
geom=prepare_track_geometry(track,rawc);
blocked_geom=geom; blocked_geom.available_half_width_m=.2;
lap=simulate_jsae_lap(blocked_geom,car,p,c);
count=count+check(~lap.screened && isinf(lap.lap_time_s), ...
    'Narrow corridor cannot produce a valid lap');
cc=c; cc.path_scale_mode='uniform_to_declared_length';
cc.track_declared_length_m=2*track.length_m;
scaled=prepare_track_geometry(track,cc);
count=count+check(abs(scaled.length_m-2*geom.length_m)<1e-8 && ...
    max(abs(scaled.kappa-geom.kappa/2))<1e-9, ...
    'Uniform path scaling transforms curvature and length consistently');
% A closed circle at 1g and constant speed has analytic lap time 2*pi*R/v.
n=120; R=30; synthetic=geom;
synthetic.kappa=ones(n,1)/R; synthetic.corner_dir=ones(n,1);
synthetic.segment_length_m=ones(n,1)*(2*pi*R/n);
synthetic.length_m=2*pi*R;
lap=simulate_jsae_lap(synthetic,free(1),p,c);
expected_v=min(sqrt(c.cornering_safety_factor*free(1).Ay_capacity*p.g*R), ...
    c.max_speed_kph/3.6);
count=count+check(lap.converged && abs(lap.lap_time_s-2*pi*R/expected_v)<1e-9, ...
    'Analytic constant-radius, constant-speed lap');
for j=[1,numel(free)]
    lap=simulate_jsae_lap(geom,free(j),p,c);
    count=count+check(lap.screened && lap.max_front_utilisation<=1+1e-9 && ...
        lap.max_rear_utilisation<=1+1e-9 && lap.minimum_wheel_load_N>0, ...
        'Full supplied track completes with physically feasible axle demand');
    [v2,converged]=solve_speed_profile(lap.speed_mps,geom.kappa, ...
        geom.segment_length_m,free(j).Ay_capacity*p.g,c);
    count=count+check(converged && max(abs(v2-lap.speed_mps))<1e-8, ...
        'Periodic speed solution remains unchanged on continuation');
end
% No cornering-only claim may be labelled a validated geometry or yaw result.
count=count+check(~any([free.geometry_validated]), ...
    'Unmodelled hardpoints are explicitly unvalidated');
test=p; test.IR_f=1; test.IR_r=1;
ca=c; cb=c; ca.motion_ratio_convention='spring_over_wheel';
cb.motion_ratio_convention='wheel_over_spring';
a=calculate_four_wheel(test,widths,ca,'fixed_wheel_rate');
b=calculate_four_wheel(test,widths,cb,'fixed_wheel_rate');
count=count+check(max(abs([a.Ay_capacity]-[b.Ay_capacity]))<1e-12, ...
    'Unit motion ratio is independent of convention');
rejected=false;
try
    calculate_four_wheel(p,p.T_f/4,c,'fixed_axle_roll_stiffness');
catch problem
    rejected=~isempty(strfind(problem.message,'tyre-limited ride rate'));
end
count=count+check(rejected, ...
    'Unreachable held roll stiffness rejects an impossible spring solution');
if exist('OCTAVE_VERSION','builtin')
    temporary=tempname; mkdir(temporary); mkdir(fullfile(temporary,'input'));
    cleanup=onCleanup(@() rmdir(temporary,'s'));
    copyfile(fullfile(root,'input','FSAE_VD_3_KASAR .xlsx'),fullfile(temporary,'input'));
    copyfile(fullfile(root,'input','study_inputs.json'),fullfile(temporary,'input'));
    f=fopen(fullfile(temporary,'input','FSAE_VD_3_KASAR .xlsx'),'a');
    fwrite(f,32); fclose(f);
    rejected=false;
    try
        read_study_inputs(temporary);
    catch problem
        rejected=~isempty(strfind(problem.message,'Workbook content changed'));
    end
    count=count+check(rejected,'Modified workbook rejects a stale JSON snapshot');
end
fprintf('\nPASS: %d model checks completed.\n',count);
end

function result = check(condition,label)
assert(all(condition(:)),label);
fprintf('PASS: %s\n',label); result=1;
end
