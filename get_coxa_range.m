function get_coxa_range()
    
    angles = zeros(1, 24);

    coords = get_spider_coords(angles);

    for i=1:3
        leg_pair = 
    end

    for i=1:3
        MAX_ANGLE = 0;
        LEG_LENGTH = 2.9;

        DISTANCE_BETWEEN_POINTS = sqrt(...
            (coords{i}(1) - coords{i + 1}(1)) ^ 2 + ...
            (coords{i}(2) - coords{i + 1}(2)) ^ 2 ...
        );

        MAX_ANGLE = acos((DISTANCE_BETWEEN_POINTS / 2)/ LEG_LENGTH);

        fprintf("Leg %d max coxa angle: %.2f degrees\n", i, rad2deg(MAX_ANGLE));
    end
end