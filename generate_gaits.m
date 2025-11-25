function gaits = generate_gaits(population, NUM_OF_FRAMES)
    gaits = cell(1, length(population));

    for i=1:length(population)
        gaits{i} = generate_gait(population{i}, NUM_OF_FRAMES);
    end
end


function gait = generate_gait(chromsome, NUM_OF_FRAMES)
    gait = {};
    INITIAL_FRAME = initial_frame();
    previous_frame = INITIAL_FRAME;

    for i=1:NUM_OF_FRAMES
        frame = generate_frame(chromsome, previous_frame);
        gait{i} = frame;
        previous_frame = frame;
    end
end

function frame = generate_frame(chromosome, previous_frame)
    global GA_PARAMS;
    % Generate a new frame from the previous one using the chromosome as a
    % simple linear controller, but enforce hard constraints:
    % - maximum per-step angle change
    % - joint angle limits

    n_joints = length(previous_frame);
    frame = zeros(1, n_joints);

    % Controller: for each joint we predict a desired delta from a slice of
    % the chromosome, then clamp that delta and the resulting angle.
    MAX_ANGLE_DELTA = GA_PARAMS.MAX_ANGLE_DELTA;

    % Reasonable global bounds for all joints (in radians)
    MIN_ANGLE = GA_PARAMS.MIN_ANGLE;
    MAX_ANGLE = GA_PARAMS.MAX_ANGLE;

    % Each joint uses a contiguous block of weights
    weights_per_joint = floor(length(chromosome) / n_joints);
    if weights_per_joint < 1
        % Fallback: no meaningful mapping, keep previous frame
        frame = previous_frame;
        return;
    end

    for i = 1:n_joints
        idx_start = (i-1) * weights_per_joint + 1;
        idx_end   = idx_start + weights_per_joint - 1;
        if idx_end > length(chromosome)
            idx_end = length(chromosome);
        end

        w = chromosome(idx_start:idx_end);

        % Very small input feature vector: just the previous joint angle and
        % a bias term. If more complex behaviour is needed, extend this.
        x = [previous_frame(i); 1];
        if numel(w) < numel(x)
            % Pad weights if chromosome is small
            w = [w(:); zeros(numel(x) - numel(w), 1)];
        else
            w = w(1:numel(x));
        end

        desired_delta = dot(w, x);

        % Clamp delta to match "rule" from get_fitness
        desired_delta = max(-MAX_ANGLE_DELTA, min(MAX_ANGLE_DELTA, desired_delta));

        new_angle = previous_frame(i) + desired_delta;

        % Clamp joint angle to a global range
        new_angle = max(MIN_ANGLE, min(MAX_ANGLE, new_angle));

        frame(i) = new_angle;
    end
end