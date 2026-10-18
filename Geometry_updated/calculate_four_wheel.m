function cars = calculate_four_wheel(p, tracks, c, mode)
% Two controlled scenarios; no hardpoint-derived geometry or structure claims.
assert(any(strcmp(mode,{'fixed_wheel_rate','fixed_axle_roll_stiffness'})));
if strcmp(c.motion_ratio_convention,'spring_over_wheel')
    kwf=p.K_sf*p.IR_f^2; kwr=p.K_sr*p.IR_r^2;
else
    kwf=p.K_sf/p.IR_f^2; kwr=p.K_sr/p.IR_r^2;
end
ride_f=kwf*p.K_tf/(kwf+p.K_tf);
ride_r=kwr*p.K_tr/(kwr+p.K_tr);
% K [Nm/rad] = k [N/mm]*t[mm]^2/2000, then multiply pi/180.
factor=pi/(180*2000);
base_kf=ride_f*p.T_f^2*factor+p.K_arbf;
kr=ride_r*p.T_r^2*factor+p.K_arbr;
cars=struct([]);
for j=1:numel(tracks)
    car=struct();
    car.T_f=tracks(j); car.T_r=p.T_r; car.mode=mode;
    car.front_ride_rate_Npmm=ride_f;
    if strcmp(mode,'fixed_axle_roll_stiffness')
        car.front_ride_rate_Npmm=ride_f*(p.T_f/car.T_f)^2;
    end
    assert(car.front_ride_rate_Npmm<p.K_tf, ...
        'Requested held roll stiffness exceeds the tyre-limited ride rate.');
    car.K_phi_f=car.front_ride_rate_Npmm*car.T_f^2*factor+p.K_arbf;
    car.K_phi_r=kr;
    car.K_phi_total=car.K_phi_f+car.K_phi_r;
    car.front_roll_fraction=car.K_phi_f/car.K_phi_total;
    equivalent_kw=car.front_ride_rate_Npmm*p.K_tf/ ...
        (p.K_tf-car.front_ride_rate_Npmm);
    if strcmp(c.motion_ratio_convention,'spring_over_wheel')
        car.equivalent_front_spring_Npmm=equivalent_kw/p.IR_f^2;
    else
        car.equivalent_front_spring_Npmm=equivalent_kw*p.IR_f^2;
    end
    % Sprung axle fractions derived from total axle weights and unsprung mass.
    df=p.m_uf*p.g*p.h_uf/car.T_f+p.m_sf*p.g*p.z_RF/car.T_f + ...
        car.front_roll_fraction*p.M_R_per_g/(car.T_f/1000);
    dr=p.m_ur*p.g*p.h_ur/car.T_r+p.m_sr*p.g*p.z_RR/car.T_r + ...
        (1-car.front_roll_fraction)*p.M_R_per_g/(car.T_r/1000);
    car.transfer_per_g=[df;dr];
    assert(df>0 && dr>0);
    car.Ay_lift_g=min([p.W_total*p.WD_f/2/df, ...
        p.W_total*(1-p.WD_f)/2/dr]);
    % First feasibility boundary: axle force balance or wheel lift.
    lo=0; hi=car.Ay_lift_g;
    for iteration=1:70
        mid=(lo+hi)/2;
        state=four_wheel_state(p,car,mid);
        if all(state.axle_demand_N<=state.axle_capacity_N) && ...
                all(state.Fz_N>=0)
            lo=mid;
        else
            hi=mid;
        end
    end
    car.Ay_capacity=lo;
    state=four_wheel_state(p,car,lo);
    [~,which]=max(state.axle_utilisation);
    labels={'Front','Rear'};
    car.limiting_axle=labels{which};
    if abs(lo-car.Ay_lift_g)<1e-7, car.limiting_axle='WheelLift'; end
    car.phi_roll_at_target=p.M_R_per_g*p.A_y/car.K_phi_total;
    target=four_wheel_state(p,car,p.A_y);
    car.target_min_wheel_load_N=min(target.Fz_N);
    car.target_front_utilisation=target.axle_utilisation(1);
    car.target_rear_utilisation=target.axle_utilisation(2);
    % Proxy only: complete front unsprung axle mass lumped at wheel centres.
    % Excludes sprung parts and extra mass of longer arms; NOT a yaw model.
    car.delta_Iz_front_unsprung_proxy=p.m_uf/4* ...
        ((car.T_f/1000)^2-(p.T_f/1000)^2);
    car.geometry_validated=false;
    cars(j)=car;
end
end
