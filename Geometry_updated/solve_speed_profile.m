function [v,converged,passes] = solve_speed_profile(limit,kappa,ds,ay_limit,c)
% Periodic forward/backward friction-ellipse envelope on one fixed path.
v=limit(:); kappa=abs(kappa(:)); ds=ds(:); n=numel(v);
converged=false;
for passes=1:c.speed_profile_iterations
    before=v;
    for i=1:n
        next=mod(i,n)+1;
        ratio=min(v(i)^2*kappa(i)/max(ay_limit,eps),1);
        ax=c.max_accel_mps2*sqrt(max(1-ratio^2,0));
        v(next)=min(v(next),sqrt(v(i)^2+2*ax*ds(i)));
    end
    for i=n:-1:1
        previous=mod(i-2,n)+1;
        ratio=min(v(i)^2*kappa(i)/max(ay_limit,eps),1);
        brake=c.max_brake_mps2*sqrt(max(1-ratio^2,0));
        v(previous)=min(v(previous),sqrt(v(i)^2+2*brake*ds(previous)));
    end
    if max(abs(v-before))<c.speed_convergence_mps
        converged=true; break;
    end
end
end
