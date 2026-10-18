function geom = prepare_track_geometry(track,c)
% Fixed path shared by every candidate. No clearance-based curvature shortcut.
p=track.xy_m;
scale=1;
if strcmp(c.path_scale_mode,'uniform_to_declared_length')
    scale=c.track_declared_length_m/track.length_m;
end
p=p*scale;
ds=track.segment_length_m*scale;
n=size(p,1);
assert(c.curvature_smoothing_points<n/2, 'Curvature window too large.');
half=max(1,floor(c.curvature_smoothing_points/2));
kappa=zeros(n,1);
for i=1:n
    ia=mod(i-1-half,n)+1; ic=mod(i-1+half,n)+1;
    ab=p(i,:)-p(ia,:); bc=p(ic,:)-p(i,:); ca=p(ia,:)-p(ic,:);
    denominator=norm(ab)*norm(bc)*norm(ca);
    if denominator>1e-12
        kappa(i)=2*(ab(1)*bc(2)-ab(2)*bc(1))/denominator;
    end
end
smooth_win=max(1,round(c.curvature_smoothing_points/3));
original=kappa;
for i=1:n
    idx=mod((i-floor(smooth_win/2)-1):(i+ceil(smooth_win/2)-2),n)+1;
    kappa(i)=mean(original(idx));
end
assert(all(ds>0) && all(isfinite(kappa)), 'Degenerate track points.');
geom.xy_m=p; geom.segment_length_m=ds;
geom.distance_m=[0;cumsum(ds(1:end-1))];
geom.length_m=sum(ds); geom.raw_spline_length_m=track.length_m;
geom.distance_scale=scale; geom.kappa=kappa;
geom.corner_dir=sign(kappa);
geom.available_half_width_m=c.track_width_m/2-c.cone_safety_margin_m;
end
