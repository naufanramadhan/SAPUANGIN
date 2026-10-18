function track = read_ac_ai_spline(file_path)
% READ_AC_AI_SPLINE Read the base point records from an Assetto Corsa AI spline.

file_id = fopen(file_path, 'rb', 'ieee-le');
assert(file_id >= 0, 'Tidak dapat membuka track AI: %s', file_path);
cleanup = onCleanup(@() fclose(file_id));

track.version = fread(file_id, 1, 'int32=>double');
point_count = fread(file_id, 1, 'int32=>double');
fread(file_id, 2, 'int32=>double');
assert(track.version >= 1 && point_count > 2, ...
    'Header fast_lane.ai tidak valid: %s', file_path);

points = zeros(point_count, 3);
distance_raw = zeros(point_count, 1);
point_index = zeros(point_count, 1);
for point_id = 1:point_count
    points(point_id, :) = fread(file_id, 3, 'single=>double').';
    distance_raw(point_id) = fread(file_id, 1, 'single=>double');
    point_index(point_id) = fread(file_id, 1, 'int32=>double');
end

assert(all(point_index == (0:point_count - 1).'), ...
    'Urutan point fast_lane.ai tidak valid: %s', file_path);

segment_length = hypot(diff(points(:, 1)), diff(points(:, 3)));
closing_length = hypot(points(1, 1) - points(end, 1), ...
    points(1, 3) - points(end, 3));

track.file_path = file_path;
track.point_count = point_count;
track.xyz_m = points;
track.xy_m = points(:, [1, 3]);
track.distance_raw_m = distance_raw;
track.segment_length_m = [segment_length; closing_length];
track.distance_m = [0; cumsum(segment_length)];
track.length_m = sum(track.segment_length_m);
end