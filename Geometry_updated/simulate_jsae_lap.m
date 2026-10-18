function lap = simulate_jsae_lap(geom,car,p,c)
% Quasi-steady screening on supplied fixed spline; not a path-following model.
lap=struct();
lap.vehicle_width_m=(max(car.T_f,car.T_r)+c.tire_section_width_mm)/1000;
lap.corridor_clearance_m=geom.available_half_width_m-lap.vehicle_width_m/2;
% Width-only clearance does NOT certify a swept envelope through cones.
lap.lap_time_s=inf; lap.average_speed_kph=0;
lap.max_tire_utilisation=NaN; lap.minimum_wheel_load_N=NaN;
lap.max_front_utilisation=NaN; lap.max_rear_utilisation=NaN;
lap.screened=false; lap.converged=false; lap.speed_passes=0;
lap.max_speed_kph=0;
n=numel(geom.kappa);
lap.speed_mps=zeros(n,1); lap.Ay_g=zeros(n,1);
lap.wheel_load_N=nan(4,n); lap.tire_utilisation=nan(4,n);
if lap.corridor_clearance_m<=0 || car.Ay_capacity<=0, return; end
ay_limit=car.Ay_capacity*p.g;
limit=min(sqrt(c.cornering_safety_factor*ay_limit./ ...
    max(abs(geom.kappa),eps)), c.max_speed_kph/3.6);
[v,converged,passes]=solve_speed_profile(limit,geom.kappa, ...
    geom.segment_length_m,ay_limit,c);
lap.converged=converged; lap.speed_passes=passes;
lap.speed_mps=v;
lap.Ay_g=v.^2.*abs(geom.kappa)/p.g;
state=four_wheel_state(p,car,lap.Ay_g,geom.corner_dir);
lap.wheel_load_N=state.Fz_N;
lap.tire_utilisation=state.wheel_utilisation;
lap.max_tire_utilisation=max(state.axle_utilisation(:));
lap.max_front_utilisation=max(state.axle_utilisation(1,:));
lap.max_rear_utilisation=max(state.axle_utilisation(2,:));
lap.minimum_wheel_load_N=min(state.Fz_N(:));
lap.max_speed_kph=max(v)*3.6;
lap.screened=converged && lap.max_tire_utilisation<=1+1e-9 && ...
    lap.minimum_wheel_load_N>=-1e-9;
if lap.screened
    lap.lap_time_s=sum(2*geom.segment_length_m./max(v+circshift(v,-1),eps));
    lap.average_speed_kph=geom.length_m/lap.lap_time_s*3.6;
end
end
