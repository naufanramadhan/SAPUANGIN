function state = four_wheel_state(p, car, Ay_g, direction)
% Steady lateral state only: no aero, longitudinal transfer or transient roll.
% Order FL, FR, RL, RR. Ay_g is a nonnegative magnitude.
if nargin<4, direction=1; end
Ay_g = Ay_g(:).';
direction = direction(:).';
assert(all(Ay_g>=0) && (isscalar(direction) || numel(direction)==numel(Ay_g)));
static = p.W_total*[p.WD_f;p.WD_f;1-p.WD_f;1-p.WD_f]/2;
d = car.transfer_per_g(:)*Ay_g;
state.Fz_N = repmat(static,1,numel(Ay_g)) + ...
    [-d(1,:);d(1,:);-d(2,:);d(2,:)].*repmat(direction,4,1);
Fz = max(state.Fz_N,0);
mu0 = [p.mu_0f;p.mu_0f;p.mu_0r;p.mu_0r];
slope = [p.dmu_dFz_f;p.dmu_dFz_f;p.dmu_dFz_r;p.dmu_dFz_r];
ref = [p.F_z0f;p.F_z0f;p.F_z0r;p.F_z0r];
mu = max(repmat(mu0,1,numel(Ay_g)) + ...
    repmat(slope,1,numel(Ay_g)).*(Fz-repmat(ref,1,numel(Ay_g))),0);
state.capacity_N = mu.*Fz;
state.axle_capacity_N = [sum(state.capacity_N(1:2,:),1); ...
    sum(state.capacity_N(3:4,:),1)];
state.axle_demand_N = p.W_total*[p.WD_f;1-p.WD_f]*Ay_g;
state.axle_utilisation = state.axle_demand_N./max(state.axle_capacity_N,eps);
% Proportional allocation is bookkeeping, not a slip-angle tyre solution.
state.wheel_utilisation = state.axle_utilisation([1,1,2,2],:);
state.wheel_utilisation(Fz<=0) = 0;
state.wheel_lift = any(state.Fz_N<=0,1);
end
