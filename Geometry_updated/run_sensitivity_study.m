function report = run_sensitivity_study(p,c,geom,out)
% Analyst-selected perturbations, NOT measured uncertainty or confidence bounds.
% Compare only measured baseline and maximum proposed width to keep this small.
mu=c.sensitivity_mu_fraction; dh=c.sensitivity_h_mm;
sample_names={'nominal','low_grip_low_CG','low_grip_high_CG', ...
    'high_grip_low_CG','high_grip_high_CG','alternate_MR_definition'};
settings=[1,0;1-mu,-dh;1-mu,dh;1+mu,-dh;1+mu,dh;1,0];
modes={'fixed_wheel_rate','fixed_axle_roll_stiffness'};
headers={'Sample','GripCurveScale','CGHeight_mm','MotionRatioConvention', ...
    'Scenario','BaselineFrontTrack_mm','CandidateFrontTrack_mm','RearTrack_mm', ...
    'BaselineCapacity_g','CandidateCapacity_g','BaselineLapTime_s', ...
    'CandidateLapTime_s','DeltaLapTime_s','BothScreened'};
rows=cell(numel(sample_names)*numel(modes),numel(headers)); cursor=0;
for k=1:numel(sample_names)
    pp=p; cc=c;
    scale=settings(k,1);
    pp.mu_0f=p.mu_0f*scale; pp.mu_0r=p.mu_0r*scale;
    pp.dmu_dFz_f=p.dmu_dFz_f*scale; pp.dmu_dFz_r=p.dmu_dFz_r*scale;
    pp.h=p.h+settings(k,2);
    pp.h_s=(pp.m_total*pp.h-pp.m_uf*pp.h_uf-pp.m_ur*pp.h_ur)/pp.m_s;
    pp.M_R_per_g=pp.m_s*pp.g*(pp.h_s-pp.z_RA)/1000;
    assert(pp.h_s>pp.z_RA, 'Sensitivity CG falls below roll axis.');
    if k==numel(sample_names)
        if strcmp(c.motion_ratio_convention,'spring_over_wheel')
            cc.motion_ratio_convention='wheel_over_spring';
        else
            cc.motion_ratio_convention='spring_over_wheel';
        end
    end
    for s=1:numel(modes)
        cars=calculate_four_wheel(pp,[pp.T_f,c.front_track_max_mm],cc,modes{s});
        a=simulate_jsae_lap(geom,cars(1),pp,cc);
        b=simulate_jsae_lap(geom,cars(2),pp,cc);
        cursor=cursor+1;
        delta=NaN;
        if a.screened && b.screened, delta=b.lap_time_s-a.lap_time_s; end
        rows(cursor,:)={sample_names{k},scale,pp.h,cc.motion_ratio_convention, ...
            modes{s},pp.T_f,c.front_track_max_mm,pp.T_r, ...
            cars(1).Ay_capacity,cars(2).Ay_capacity,a.lap_time_s, ...
            b.lap_time_s,delta,a.screened && b.screened};
    end
end
write_study_csv(fullfile(out,'sensitivity_baseline_vs_candidate.csv'),headers,rows);
report.headers=headers; report.rows=rows;
fprintf('Sensitivity: %d endpoint comparisons saved. Perturbations are assumptions.\n',size(rows,1));
end
