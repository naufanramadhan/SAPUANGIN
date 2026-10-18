function study = run_trackwidth_study(root,make_plots)
% Actual numeric workflow shared by MATLAB and Octave.
if nargin<1, root=fileparts(mfilename('fullpath')); end
if nargin<2, make_plots=~exist('OCTAVE_VERSION','builtin'); end
addpath(root);
[p,c]=read_study_inputs(root);
tracks=unique([c.front_track_min_mm:c.track_step_mm:c.front_track_max_mm, ...
    p.T_f,c.front_track_max_mm]);
track=read_ac_ai_spline(fullfile(root,'input','track','fast_lane.ai'));
geom=prepare_track_geometry(track,c);
out=fullfile(root,'output'); if ~isfolder(out), mkdir(out); end
stamp=datestr(now,'yyyymmdd_HHMMSS');
run_dir=fullfile(out,['study_' stamp]); mkdir(run_dir);
modes={'fixed_wheel_rate','fixed_axle_roll_stiffness'};
headers={'Scenario','FrontTrack_mm','RearTrack_mm','FrontRollStiffness_NmPerDeg', ...
    'RearRollStiffness_NmPerDeg','FrontRollFraction','FrontRideRate_NPerMm', ...
    'EquivalentFrontSpring_NPerMm','LateralCapacity_g','LimitingAxle', ...
    'WheelLiftBoundary_g','TargetAy_g','TargetMinWheelLoad_N', ...
    'TargetFrontUtilisation','TargetRearUtilisation', ...
    'DeltaIzFrontUnsprungProxy_kgm2','LapTime_s','DeltaLapTime_s', ...
    'AverageSpeed_kph','TrackWidthOnlyClearance_m', ...
    'MinimumWheelLoad_N','MaxFrontUtilisation','MaxRearUtilisation', ...
    'SpeedConverged','SpeedPasses','LapScreened', ...
    'SkidpadLapTime_s','SkidpadTotalTime_s','SkidpadClearance_m', ...
    'IdealSteerInner_deg','IdealSteerOuter_deg','IdealSteeringFeasible', ...
    'SkidpadScreened','GeometryValidated','YawResponseEvaluated'};
rows=cell(numel(tracks)*numel(modes),numel(headers)); cursor=0;
study.params=p; study.config=c; study.geom=geom; study.tracks_mm=tracks;
study.created_at_local=datestr(now,31);
if exist('OCTAVE_VERSION','builtin')
    study.execution_engine=['GNU Octave ' OCTAVE_VERSION];
else
    study.execution_engine=['MATLAB ' version];
end
fprintf('\nFRONT-ONLY TRACK WIDTH SCREENING\n');
fprintf('Rear track fixed: %.0f mm. Proposed column F is not read.\n',p.T_r);
fprintf('Path: %.3f m; raw spline: %.3f m; scale: %.8f\n', ...
    geom.length_m,geom.raw_spline_length_m,geom.distance_scale);
fprintf('MR convention: %s -- requires confirmation from measurement.\n', ...
    c.motion_ratio_convention);
fprintf('No actual rack, arm kinematics, structural validation or yaw dynamics.\n');
for s=1:numel(modes)
    mode=modes{s};
    cars=calculate_four_wheel(p,tracks,c,mode);
    laps=struct([]); skids=struct([]);
    for j=1:numel(tracks)
        laps(j)=simulate_jsae_lap(geom,cars(j),p,c);
        skids(j)=simulate_skidpad(cars(j),p,c);
    end
    baseline=find(abs(tracks-p.T_f)<1e-9,1);
    times=[laps.lap_time_s]; valid=[laps.screened];
    [best_time,best]=min(times);
    if ~any(valid), best=NaN; best_time=inf; end
    tied=[];
    if isfinite(best_time), tied=find(abs(times-best_time)<1e-7); end
    study.scenarios(s).mode=mode;
    study.scenarios(s).vehicle=cars;
    study.scenarios(s).lap=laps;
    study.scenarios(s).skidpad=skids;
    study.scenarios(s).baseline_idx=baseline;
    study.scenarios(s).best_screened_idx=best;
    study.scenarios(s).numerically_tied_indices=tied;
    study.scenarios(s).best_is_sweep_boundary=~isnan(best) && ...
        (best==1 || best==numel(tracks));
    fprintf('\n%s\n',mode);
    fprintf(' Baseline: Ay %.5f g; lap %.4f s\n', ...
        cars(baseline).Ay_capacity,times(baseline));
    if ~isnan(best)
        fprintf(' Best screened: Tf %.0f mm; lap %.4f s; delta %+.4f s\n', ...
            tracks(best),best_time,best_time-times(baseline));
        if numel(tied)>1
            fprintf(' %d candidates tie numerically; no unique best width.\n',numel(tied));
        elseif study.scenarios(s).best_is_sweep_boundary
            fprintf(' Boundary result: optimum NOT bracketed; not a final design.\n');
        end
    else
        warning('No candidate passed the simplified event screens.');
    end
    for j=1:numel(tracks)
        car=cars(j); lap=laps(j); skid=skids(j); cursor=cursor+1;
        delta=NaN;
        if isfinite(lap.lap_time_s) && isfinite(times(baseline))
            delta=lap.lap_time_s-times(baseline);
        end
        rows(cursor,:)={mode,car.T_f,car.T_r,car.K_phi_f,car.K_phi_r, ...
            car.front_roll_fraction,car.front_ride_rate_Npmm, ...
            car.equivalent_front_spring_Npmm,car.Ay_capacity,car.limiting_axle, ...
            car.Ay_lift_g,p.A_y,car.target_min_wheel_load_N, ...
            car.target_front_utilisation,car.target_rear_utilisation, ...
            car.delta_Iz_front_unsprung_proxy,lap.lap_time_s,delta, ...
            lap.average_speed_kph,lap.corridor_clearance_m, ...
            lap.minimum_wheel_load_N,lap.max_front_utilisation, ...
            lap.max_rear_utilisation,lap.converged,lap.speed_passes,lap.screened, ...
            skid.lap_time_s,skid.total_time_s,skid.corridor_clearance_m, ...
            skid.steer_inner_deg,skid.steer_outer_deg,skid.steering_feasible, ...
            skid.screened,false,false};
    end
    trace_headers={'Distance_m','Curvature_PerM','BaselineSpeed_kph', ...
        'CandidateMaxWidthSpeed_kph','BaselineAy_g','CandidateMaxWidthAy_g'};
    trace=[geom.distance_m,geom.kappa,laps(baseline).speed_mps*3.6, ...
        laps(end).speed_mps*3.6,laps(baseline).Ay_g,laps(end).Ay_g];
    write_study_csv(fullfile(run_dir,['trace_' mode '.csv']), ...
        trace_headers,num2cell(trace));
end
write_study_csv(fullfile(run_dir,'track_width_study.csv'),headers,rows);
if c.run_sensitivity
    study.sensitivity=run_sensitivity_study(p,c,geom,run_dir);
end
study.output_dir=run_dir;
save(fullfile(run_dir,'track_width_study.mat'),'study','-v7');
input_source=fullfile(root,'input','FSAE_VD_3_KASAR .xlsx');
copyfile(input_source,fullfile(run_dir,'inputs_used.xlsx'));
if exist('OCTAVE_VERSION','builtin')
    copyfile(fullfile(root,'input','study_inputs.json'), ...
        fullfile(run_dir,'inputs_used.json'));
end
f=fopen(fullfile(run_dir,'RUN_NOTES.txt'),'w');
assert(f>=0); cleanup=onCleanup(@() fclose(f));
fprintf(f,'Engine: %s\nRun timestamp: %s\n', ...
    study.execution_engine,study.created_at_local);
fprintf(f,'Front-only study; rear track %.0f mm. Two roll-stiffness scenarios.\n',p.T_r);
fprintf(f,'Path length %.6f m; scale %.9f. Assetto Corsa spline, unverified JSAE geometry.\n', ...
    geom.length_m,geom.distance_scale);
fprintf(f,'MR convention %s inherited from original multiplication formula; verify actual definition.\n', ...
    c.motion_ratio_convention);
fprintf(f,'Force capacity requires each axle to meet its steady-state demand. Wheel lift is a boundary.\n');
fprintf(f,'Times are screening estimates. No transient yaw, driver, aero, actual steering mechanism,\n');
fprintf(f,'arm hardpoints, added mass, structural SF or complete swept-envelope validation.\n');
fprintf(f,'Proposed column F and historical Excel dashboard are not study outputs.\n');
if make_plots, plot_study_results(study); end
fprintf('\nSaved: %s\n',run_dir);
end
