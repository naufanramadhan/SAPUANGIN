function skid = simulate_skidpad(car,p,c)
% Fixed CG path, ideal no-slip steering reference; actual rack not modelled.
R=c.skidpad_inner_diameter_m/2+c.skidpad_lane_width_m/2;
b=p.L*p.WD_f/1000; L=p.L/1000;
assert(R>b, 'Skidpad radius is smaller than CG-to-rear-axle distance.');
rear_radius=sqrt(R^2-b^2);
skid.path_radius_m=R;
skid.steer_inner_deg=atan2d(L,rear_radius-car.T_f/2000);
skid.steer_outer_deg=atan2d(L,rear_radius+car.T_f/2000);
skid.steering_feasible=max([skid.steer_inner_deg,skid.steer_outer_deg]) ...
    <=c.skidpad_max_steer_deg;
skid.ackermann_delta_deg=skid.steer_inner_deg-skid.steer_outer_deg;
wheel_radii=[hypot(L,rear_radius-car.T_f/2000), ...
    hypot(L,rear_radius+car.T_f/2000), ...
    rear_radius-car.T_r/2000,rear_radius+car.T_r/2000];
half_tire=c.tire_section_width_mm/2000;
inner=c.skidpad_inner_diameter_m/2;
outer=inner+c.skidpad_lane_width_m;
% Wheel-centre radii plus half tyre width; chassis overhang not supplied.
skid.corridor_clearance_m=min([min(wheel_radii)-half_tire-inner, ...
    outer-max(wheel_radii)-half_tire])-c.cone_safety_margin_m;
skid.speed_kph=NaN; skid.lap_time_s=inf; skid.total_time_s=inf;
skid.minimum_wheel_load_N=NaN; skid.max_tire_utilisation=NaN;
skid.wheel_load_N=nan(4,1); skid.wheel_utilisation=nan(4,1);
skid.screened=false;
if ~skid.steering_feasible || skid.corridor_clearance_m<=0, return; end
v=min(sqrt(c.cornering_safety_factor*car.Ay_capacity*p.g*R), ...
    c.max_speed_kph/3.6);
state=four_wheel_state(p,car,v^2/(R*p.g),1);
skid.speed_kph=v*3.6;
skid.minimum_wheel_load_N=min(state.Fz_N);
skid.max_tire_utilisation=max(state.axle_utilisation);
skid.wheel_load_N=state.Fz_N;
skid.wheel_utilisation=state.wheel_utilisation;
skid.screened=skid.minimum_wheel_load_N>=-1e-9 && ...
    skid.max_tire_utilisation<=1+1e-9;
if skid.screened
    skid.lap_time_s=2*pi*R/v;
    skid.total_time_s=2*c.skidpad_timed_laps_per_direction*skid.lap_time_s;
end
end
