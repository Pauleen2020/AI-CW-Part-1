function get_coxa_range()
    
    angles = zeros(1, 24);

    coords = get_spider_coords(angles);

    MAX_ANGLES = zeros(1, 8);

    for i=1:2
        MAX_ANGLE = 0;
        LEG_LENGTH = 2.9;

        DISTANCE_BETWEEN_POINTS = sqrt(...
            (coords{i}(1) - coords{i + 1}(1)) ^ 2 + ...
            (coords{i}(2) - coords{i + 1}(2)) ^ 2 ...
        );

        MAX_ANGLE = rad2deg(acos((DISTANCE_BETWEEN_POINTS / 2)/ LEG_LENGTH));
        MAX_ANGLES(i) = 90 - MAX_ANGLE;

        fprintf("Leg %d max coxa angle: %.2f degrees\n", i, rad2deg(MAX_ANGLE));
    end

    MAX_ANGLES(4) = MAX_ANGLES(1);
    MAX_ANGLES(5) = MAX_ANGLES(1);
    MAX_ANGLES(8) = MAX_ANGLES(1);

    MAX_ANGLES(3) = MAX_ANGLES(2);
    MAX_ANGLES(6) = MAX_ANGLES(2);
    MAX_ANGLES(7) = MAX_ANGLES(2);

    disp(MAX_ANGLES);
end