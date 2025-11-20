function fitness = get_fitness(angles, prev_angles)
    % All stationary feet need to be on the same plane
    % All stationary feet needs to be below the head of the spider
    % Legs cannot interset
    % Each joint needs a maximum delta
    % Each segment should have locked range of motion

    MAX_ANGLES = get_coxa_range();
    MIN_FOOT_HEIGHT = 0;
    MAX_ANGLE_DELTA = 1;


    OVERLAPPING_LEGS_FITNESS_SCALAR = -1;
    FEET_THROUGH_FLOOR_SCALAR = -1;
    ANGLE_CHANGE_SCALAR = -0.1; % each degree passed the delta = -0.1

    CURRENT_SPIDER_COORDS = get_spider_coords(angles);


    fitness = 0;

    % No overlapping legs
    NUM_OF_OVERLAPPING_LEGS = 0;
    for i=1:8
        if angles(1 + (i - 1) * 3) >= MAX_ANGLES(i)
            NUM_OF_OVERLAPPING_LEGS = NUM_OF_OVERLAPPING_LEGS + 1;
        end
    end
    
    fitness = fitness + (NUM_OF_OVERLAPPING_LEGS * OVERLAPPING_LEGS_FITNESS_SCALAR);


    % Feet on the floor
    NUM_OF_FEET_THROUGH_FLOOR = 0;
    for i=1:8
        if CURRENT_SPIDER_COORDS{i}(3) <= MIN_FOOT_HEIGHT
            NUM_OF_FEET_THROUGH_FLOOR = NUM_OF_FEET_THROUGH_FLOOR + 1;
        end
    end

    fitness = fitness + (NUM_OF_FEET_THROUGH_FLOOR * FEET_THROUGH_FLOOR_SCALAR);

    % Angle delta check
    TOTAL_ANGLE_DELTA_EXCEEDED = 0;
    for i=1:8
        for j=1:3
            if abs(angles(j + (i - 1) * 3) - prev_angles(j + (i - 1) * 3)) > MAX_ANGLE_DELTA
                TOTAL_ANGLE_DELTA_EXCEEDED = TOTAL_ANGLE_DELTA_EXCEEDED + ...
                    abs(angles(j + (i - 1) * 3) - prev_angles(j + (i - 1) * 3)) - MAX_ANGLE_DELTA;
            end
        end
    end

    fitness = fitness + (TOTAL_ANGLE_DELTA_EXCEEDED * ANGLE_CHANGE_SCALAR);
end