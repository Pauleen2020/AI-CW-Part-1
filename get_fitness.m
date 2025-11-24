function fitness = get_fitness(angles, prev_angles)
    % All stationary feet need to be on the same plane
    % All stationary feet needs to be below the head of the spider
    % Legs cannot interset
    % Each joint needs a maximum delta
    % Each segment should have locked range of motion

    MAX_ANGLES = get_coxa_range();
    MIN_FOOT_HEIGHT = 0;
    MAX_ANGLE_DELTA = 2;                 % you already set this

    OVERLAPPING_LEGS_FITNESS_SCALAR = -0.1;  % softer pose penalties
    FEET_THROUGH_FLOOR_SCALAR      = -0.1;
    ANGLE_CHANGE_SCALAR            = -0.01;  % softer change penalty

    FORWARD_MOVEMENT_SCALAR        = 8.0;    % slightly reduced, to balance harder anti-freeze

    % Movement / anti-freeze parameters (HARDER)
    MIN_MOVING_JOINTS_FOR_REWARD   = 4;      % need more joints moving to get reward
    MOVEMENT_EPSILON               = 0.01;

    LOW_MOVEMENT_PENALTY_SCALAR    = -3.0;   % much stronger penalty for freezing
    MIN_MOVING_JOINTS_THRESHOLD    = 3;      % require at least 3 joints to be moving

    CURRENT_SPIDER_COORDS = get_spider_coords(angles);
    PREV_SPIDER_COORDS    = get_spider_coords(prev_angles);


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

    % ------------------ Movement reward & HARD anti-freeze ------------------

    % Count how many joints moved more than MOVEMENT_EPSILON
    joint_deltas = abs(angles - prev_angles);
    num_moving_joints = sum(joint_deltas > MOVEMENT_EPSILON);

    % Strong penalty for almost completely static frames
    avg_delta = mean(joint_deltas);
    if avg_delta < 0.02   % ~1.1 degrees
        fitness = fitness - 1.0;   % stronger fixed penalty
    end

    % Stronger penalty if too few joints move
    if num_moving_joints < MIN_MOVING_JOINTS_THRESHOLD
        fitness = fitness + LOW_MOVEMENT_PENALTY_SCALAR;  % e.g. -3
    end

    % Reward foot motion in X (either direction) when enough joints participate
    if num_moving_joints >= MIN_MOVING_JOINTS_FOR_REWARD
        total_foot_motion_x = 0;
        num_legs_moving_in_x = 0;
        for i = 1:8
            prev_foot = PREV_SPIDER_COORDS{i}(end, :);    % foot (end effector)
            curr_foot = CURRENT_SPIDER_COORDS{i}(end, :);

            dx = curr_foot(1) - prev_foot(1);
            step_distance = abs(dx);
            if step_distance > 0
                total_foot_motion_x = total_foot_motion_x + step_distance;
                num_legs_moving_in_x = num_legs_moving_in_x + 1;
            end
        end

        % Main reward: how much the feet move along X in total
        fitness = fitness + FORWARD_MOVEMENT_SCALAR * total_foot_motion_x;

        % Extra: small bonus for using more legs in propulsion
        fitness = fitness + 0.5 * num_legs_moving_in_x;
    end
end