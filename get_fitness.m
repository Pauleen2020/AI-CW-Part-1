function fitness = get_fitness(angles, prev_angles)
    global GA_PARAMS;
    % All stationary feet need to be on the same plane
    % All stationary feet needs to be below the head of the spider
    % Legs cannot interset
    % Each joint needs a maximum delta
    % Each segment should have locked range of motion

    MAX_ANGLES = get_coxa_range();
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
    
    fitness = fitness + (NUM_OF_OVERLAPPING_LEGS * GA_PARAMS.OVERLAPPING_LEGS_FITNESS_SCALAR);

    % Feet on / through the floor
    NUM_OF_FEET_THROUGH_FLOOR = 0;
    for i=1:8
        foot_z = CURRENT_SPIDER_COORDS{i}(4,3);  % foot end-effector z
        if foot_z < GA_PARAMS.MIN_FOOT_HEIGHT
            NUM_OF_FEET_THROUGH_FLOOR = NUM_OF_FEET_THROUGH_FLOOR + 1;
        end
    end
    fitness = fitness + (NUM_OF_FEET_THROUGH_FLOOR * GA_PARAMS.FEET_THROUGH_FLOOR_SCALAR);

    % Angle delta check
    TOTAL_ANGLE_DELTA_EXCEEDED = 0;
    for i=1:8
        for j=1:3
            if abs(angles(j + (i - 1) * 3) - prev_angles(j + (i - 1) * 3)) > GA_PARAMS.MAX_ANGLE_DELTA
                TOTAL_ANGLE_DELTA_EXCEEDED = TOTAL_ANGLE_DELTA_EXCEEDED + ...
                    abs(angles(j + (i - 1) * 3) - prev_angles(j + (i - 1) * 3)) - GA_PARAMS.MAX_ANGLE_DELTA;
            end
        end
    end
    fitness = fitness + (TOTAL_ANGLE_DELTA_EXCEEDED * GA_PARAMS.ANGLE_CHANGE_SCALAR);

    % ---------------- Stance stability & plane consistency -----------------
    stance_z_values = [];
    for i=1:8
        prev_foot = PREV_SPIDER_COORDS{i}(4,:);
        curr_foot = CURRENT_SPIDER_COORDS{i}(4,:);
        horiz_disp = norm(curr_foot(1:2) - prev_foot(1:2));
        foot_z     = curr_foot(3);

        if horiz_disp <= GA_PARAMS.STANCE_MOTION_THRESHOLD
            % Stance foot logic
            stance_z_values(end+1) = foot_z; %#ok<AGROW>

            % Reward for being inside band
            if abs(foot_z - GA_PARAMS.STANCE_Z_TARGET) <= GA_PARAMS.Z_BAND_TOL
                fitness = fitness + GA_PARAMS.BAND_REWARD_SCALAR;
            end

            % Penetration penalty (depth below target plane)
            if foot_z < GA_PARAMS.STANCE_Z_TARGET
                penetration_depth = GA_PARAMS.STANCE_Z_TARGET - foot_z;
                fitness = fitness + GA_PARAMS.PENETRATION_SCALAR * penetration_depth;
            end

            % Excess lift penalty (discourage drifting up while classified stance)
            if foot_z > GA_PARAMS.STANCE_Z_TARGET + GA_PARAMS.MAX_LIFT_ALLOWED
                excess_lift = foot_z - (GA_PARAMS.STANCE_Z_TARGET + GA_PARAMS.MAX_LIFT_ALLOWED);
                fitness = fitness + GA_PARAMS.EXCESS_LIFT_SCALAR * excess_lift;
            end
        end
    end

    if numel(stance_z_values) >= 3
        z_var = var(stance_z_values);
        fitness = fitness + GA_PARAMS.VARIANCE_SCALAR * z_var;  % penalize uneven stance plane
    end

    % ------------------ Movement reward & HARD anti-freeze ------------------
    joint_deltas = abs(angles - prev_angles);
    num_moving_joints = sum(joint_deltas > GA_PARAMS.MOVEMENT_EPSILON);

    % Strong penalty for almost completely static frames
    avg_delta = mean(joint_deltas);
    if avg_delta < 0.02   % ~1.1 degrees
        fitness = fitness - 1.0;   % stronger fixed penalty
    end

    % Stronger penalty if too few joints move
    if num_moving_joints < GA_PARAMS.MIN_MOVING_JOINTS_THRESHOLD
        fitness = fitness + GA_PARAMS.LOW_MOVEMENT_PENALTY_SCALAR;  % e.g. -3
    end

    % Reward foot motion in X (either direction) when enough joints participate
    if num_moving_joints >= GA_PARAMS.MIN_MOVING_JOINTS_FOR_REWARD
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
        fitness = fitness + GA_PARAMS.MOVEMENT_SCALAR * total_foot_motion_x;

        % Extra: small bonus for using more legs in propulsion
        fitness = fitness + 0.5 * num_legs_moving_in_x;
    end

    % --------- Boundary linger penalty (discourage sticking at extremes) ---------
    boundary_margin = GA_PARAMS.BOUNDARY_MARGIN;
    near_bound = (angles > GA_PARAMS.MAX_ANGLE - boundary_margin) | (angles < GA_PARAMS.MIN_ANGLE + boundary_margin);
    if any(near_bound)
        fitness = fitness + GA_PARAMS.BOUNDARY_PENALTY_SCALAR * sum(near_bound);
    end
end