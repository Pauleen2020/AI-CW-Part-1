% spider_ga_full.m
clear; close all; clc;

%% -------------------- User-tunable GA parameters --------------------
gaitFrames = 300;         % frames per gait (set lower for quick tests, e.g., 30)
numGenesPerFrame = 24;
chromosomeLength = gaitFrames * numGenesPerFrame;

popSize = 40;             % population size
maxGenerations = 200;
elitismCount = 4;
tournamentSize = 4;
crossoverRate = 0.9;
mutationProb = 0.02;      % per-gene chance
mutationStd = 0.04;       % gaussian std (radians)

minAngle = -pi/4;
maxAngle = pi/4;

saveVideo = true;        % set true to write mp4 of best gait playback
videoFilename = 'best_spider_gait.mp4';
videoFPS = 30;

rng('shuffle');

%% -------------------- Build default params for fitness --------------------
params = default_gait_params();
params.jointLimits = [pi/3, pi/4, pi/2];
params.bodyZ = 0;
params.floorZTarget = -1.0;
% weight tuning (higher means more important)
params.weights = struct('collision',4,'floorVar',3,'aboveBody',6,'pairing',5,'jointLimits',6,'temporal',4);

%% -------------------- Initialize population (flattened gaits) --------------------
population = minAngle + (maxAngle - minAngle) * rand(popSize, chromosomeLength);

%% -------------------- Logging and optional video setup --------------------
bestFitnessHistory = zeros(maxGenerations,1);
meanFitnessHistory = zeros(maxGenerations,1);

if saveVideo
    vw = VideoWriter(videoFilename, 'Motion JPEG AVI');
    vw.FrameRate = videoFPS;
    open(vw);
end

%% -------------------- Main GA loop --------------------
for gen = 1:maxGenerations
    % Evaluate fitness for each chromosome (reshape into Nframes x 24)
    fitnessVals = zeros(popSize,1);
    for i = 1:popSize
        gait = reshape(population(i,:), gaitFrames, numGenesPerFrame);
        fitnessVals(i) = evaluate_gait_fitness(gait, params);
    end

    % Logging
    [bestFit, bestIdx] = max(fitnessVals);
    bestChrom = population(bestIdx, :);
    bestFitnessHistory(gen) = bestFit;
    meanFitnessHistory(gen) = mean(fitnessVals);
    fprintf('Gen %d : best = %.4f ; mean = %.4f\n', gen, bestFit, meanFitnessHistory(gen));

    % Visualize best pose every few generations (plot one representative frame)
    if mod(gen,10) == 0 || gen == 1 || gen == maxGenerations
        bestGait = reshape(bestChrom, gaitFrames, numGenesPerFrame);
        % pick a mid gait frame to show
        midFrame = round(gaitFrames/2);
        figure(1); clf;
        plot_spider_pose(bestGait(midFrame,:));
        title(sprintf('Generation %d  best=%.4f', gen, bestFit));
        drawnow;
    end

    % Optionally record a frame of visualization for a video (just a snapshot)
    if saveVideo
        frame = getframe(gcf);
        writeVideo(vw, frame);
    end

    % Termination heuristic
    if bestFit > 0.995
        fprintf('Stopping early at gen %d (fitness %.6f)\n', gen, bestFit);
        break;
    end

    % ---------------- Selection: tournament ----------------
    matingPool = zeros(popSize, chromosomeLength);
    for i = 1:popSize
        matingPool(i,:) = tournament_select(population, fitnessVals, tournamentSize);
    end

    % ---------------- Crossover + Elitism ----------------
    offspring = zeros(popSize, chromosomeLength);
    % preserve elites
    [~, sortedIdx] = sort(fitnessVals, 'descend');
    elites = population(sortedIdx(1:elitismCount), :);

    idxOff = 1;
    while idxOff <= (popSize - elitismCount)
        if rand < crossoverRate
            p1 = matingPool(randi(popSize), :);
            p2 = matingPool(randi(popSize), :);
            % Use whole-leg-block crossover with probability 0.6, otherwise two-point
            if rand < 0.6
                [c1, c2] = whole_leg_block_crossover(p1, p2, numGenesPerFrame);
            else
                [c1, c2] = two_point_crossover_flat(p1, p2);
            end
        else
            c1 = matingPool(randi(popSize), :);
            c2 = matingPool(randi(popSize), :);
        end
        offspring(idxOff, :) = c1;
        if idxOff+1 <= popSize - elitismCount
            offspring(idxOff+1, :) = c2;
        end
        idxOff = idxOff + 2;
    end

    population = [offspring(1:popSize-elitismCount, :); elites];

    % ---------------- Mutation ----------------
    population = mutate_population_flat(population, mutationProb, mutationStd, minAngle, maxAngle);

end

% close video if used
if saveVideo
    close(vw);
end

%% -------------------- Post-run: show fitness history and best gait play --------------------
genRan = 1:gen;
figure(2); clf;
plot(genRan, bestFitnessHistory(genRan), '-r', 'LineWidth', 2); hold on;
plot(genRan, meanFitnessHistory(genRan), '-b', 'LineWidth', 1.5);
xlabel('Generation'); ylabel('Fitness'); legend('Best','Mean'); grid on;
title('GA Fitness History');

% Extract best final chromosome and show / play best gait
finalFitnessVals = zeros(popSize,1);
for i = 1:popSize
    gait = reshape(population(i,:), gaitFrames, numGenesPerFrame);
    finalFitnessVals(i) = evaluate_gait_fitness(gait, params);
end
[~, bestFinalIdx] = max(finalFitnessVals);
bestFinalGait = reshape(population(bestFinalIdx,:), gaitFrames, numGenesPerFrame);

figure(3); clf;
% Play best gait (show frames at reasonable speed)
for f = 1:gaitFrames
    plot_spider_pose(bestFinalGait(f,:));
    title(sprintf('Best gait frame %d / %d ; fitness = %.4f', f, gaitFrames, finalFitnessVals(bestFinalIdx)));
    drawnow;
    pause(1/videoFPS); % simulate playback at videoFPS
end

%% -------------------- GA helper functions --------------------

function fitness = evaluate_gait_fitness(gaitSeq, params)
    % gaitSeq: Nframes x 24
    if nargin < 2 || isempty(params)
        params = default_gait_params();
    end
    [Nframes, nGenes] = size(gaitSeq);
    if nGenes ~= 24
        error('Gait must have 24 columns (8 legs * 3 joints).');
    end
    nLegs = 8;
    segs = params.segLengths;
    baseAngles = params.baseAngles;
    a = params.a; b = params.b;

    % compute foot positions for all frames
    footPos = nan(Nframes, nLegs, 3);
    invalidFK = false(Nframes,1);
    for f = 1:Nframes
        pose = gaitSeq(f,:);
        for leg = 1:nLegs
            idx = (leg-1)*3 + (1:3);
            jointAngles = pose(idx);
            base_pos = [a * cos(baseAngles(leg)), b * sin(baseAngles(leg)), 0];
            try
                [~, ~, ~, j4] = forward_leg_kinematics2(base_pos, baseAngles(leg), jointAngles, segs);
                if any(isnan(j4)) || any(isinf(j4))
                    invalidFK(f) = true;
                end
                footPos(f,leg,:) = j4;
            catch
                invalidFK(f) = true;
            end
        end
    end

    % TERM 1: No limb collision -> pairwise foot distance per frame
    collisions = 0;
    totalChecks = Nframes * nchoosek(nLegs,2);
    for f = 1:Nframes
        P = squeeze(footPos(f,:,:)); % 8x3
        for i = 1:nLegs-1
            for j = i+1:nLegs
                dij = norm(P(i,:) - P(j,:));
                if dij < params.collisionThresh
                    collisions = collisions + 1;
                end
            end
        end
    end
    collisionScore = 1 - (collisions / max(1,totalChecks)); % 1 = perfect, 0 = total collisions

    % TERM 2: All feet same floor height (low variance in foot Z)
    allZ = reshape(footPos(:,:,3), [], 1);
    allZ = allZ(~isnan(allZ));
    if isempty(allZ)
        floorVarScore = 0;
    else
        zVar = var(allZ);
        floorVarScore = exp(-10 * zVar);
    end

    % TERM 3: Feet cannot be higher than body (Z <= bodyZ)
    aboveCount = sum(allZ > params.bodyZ);
    aboveScore = 1 - (aboveCount / max(1,numel(allZ)));

    % TERM 4: Legs should move in pairs: encourage exactly 4 stationary legs between consecutive frames
    if Nframes == 1
        pairScore = 1;
    else
        stationaryCounts = zeros(Nframes-1,1);
        unwrapped = unwrap_angles_matrix(gaitSeq);
        diffs = abs(diff(unwrapped,1,1)); % (Nframes-1) x 24
        for f = 1:(Nframes-1)
            perLegMax = zeros(1,nLegs);
            for leg = 1:nLegs
                idx = (leg-1)*3 + (1:3);
                perLegMax(leg) = max(diffs(f,idx));
            end
            stationaryCounts(f) = sum(perLegMax <= params.pairTolerance);
        end
        dev = mean(abs(stationaryCounts - 4)); % want stationaryCounts close to 4
        pairScore = exp(-1.5 * dev);
    end

    % TERM 5: Joint angle limits (hard limits per joint type)
    violations = 0;
    totalJoints = numel(gaitSeq);
    for f = 1:Nframes
        pose = gaitSeq(f,:);
        for g = 1:3:24
            if abs(pose(g))   > params.jointLimits(1); violations = violations + 1; end
            if abs(pose(g+1)) > params.jointLimits(2); violations = violations + 1; end
            if abs(pose(g+2)) > params.jointLimits(3); violations = violations + 1; end
        end
    end
    jointLimitScore = exp(-6 * (violations / max(1,totalJoints)));

    % TERM 6: Temporal smoothness (penalize large angular frequencies)
    if Nframes <= 1
        temporalScore = 1;
    else
        diffsAll = diffs; % reused above
        meanDiff = mean(diffsAll(:));
        temporalScore = exp(- (meanDiff / params.temporalScale));
    end

    % Combine with weights and normalize
    W = params.weights;
    raw = W.collision*collisionScore + W.floorVar*floorVarScore + W.aboveBody*aboveScore + ...
          W.pairing*pairScore + W.jointLimits*jointLimitScore + W.temporal*temporalScore;
    sumW = W.collision + W.floorVar + W.aboveBody + W.pairing + W.jointLimits + W.temporal;
    fitness = raw / sumW;
    fitness = max(0, min(1, fitness));

    % heavy penalty if too many invalid FK frames
    if mean(invalidFK) > 0.3
        fitness = fitness * 0.2;
    end
end

function p = default_gait_params()
    p.segLengths = [1.2, 0.7, 1.0];
    p.baseAngles = deg2rad([45,75,105,135,-135,-105,-75,-45]);
    p.a = 1.5; p.b = 1.0;           % body ellipse radii
    p.bodyZ = 0;
    p.collisionThresh = 0.08;      % meters
    p.jointLimits = [pi/3, pi/4, pi/2];
    p.pairTolerance = 0.04;        % radians for "stationary" detection
    p.floorZTarget = -1.0;
    p.temporalScale = 0.05;        % adjusts temporal penalty sensitivity
    p.weights = struct('collision',3,'floorVar',2,'aboveBody',4,'pairing',2,'jointLimits',3,'temporal',3);
end

function parent = tournament_select(population, fitnessVals, tsize)
    N = size(population,1);
    idx = randi(N, [tsize,1]);
    [~, bestLocal] = max(fitnessVals(idx));
    parent = population(idx(bestLocal), :);
end

function [c1, c2] = whole_leg_block_crossover(p1, p2, genesPerFrame)
    % Swap blocks corresponding to whole legs across random subset of frames
    % genesPerFrame = 24
    nLegs = 8;
    legBlockSize = 3; % genes per leg
    % Choose random set of legs to swap (50% chance each)
    maskLeg = rand(1, nLegs) > 0.5;
    c1 = p1; c2 = p2;
    % iterate every frame
    frameLen = genesPerFrame;
    numFrames = length(p1) / frameLen;
    for fr = 1:numFrames
        base = (fr-1)*frameLen;
        for leg = 1:nLegs
            if maskLeg(leg)
                idx = base + (leg-1)*legBlockSize + (1:legBlockSize);
                temp = c1(idx);
                c1(idx) = c2(idx);
                c2(idx) = temp;
            end
        end
    end
end

function [c1, c2] = two_point_crossover_flat(p1, p2)
    n = length(p1);
    cp = sort(randperm(n,2));
    c1 = p1; c2 = p2;
    c1(cp(1):cp(2)) = p2(cp(1):cp(2));
    c2(cp(1):cp(2)) = p1(cp(1):cp(2));
end

function pop = mutate_population_flat(population, mutProb, mutStd, minA, maxA)
    pop = population;
    [N, G] = size(pop);
    for i = 1:N
        for g = 1:G
            if rand < mutProb
                pop(i,g) = pop(i,g) + mutStd * randn;
                pop(i,g) = max(minA, min(maxA, pop(i,g)));
            end
        end
    end
end

function M = unwrap_angles_matrix(mat)
    M = zeros(size(mat));
    for j = 1:size(mat,2)
        M(:,j) = unwrap(mat(:,j));
    end
end

%% -------------------- Provided plotting and FK functions --------------------
% The following functions are adapted from your initial code and used by the GA.
% plot_spider_pose expects a 1x24 vector of joint angles (radians)

function plot_spider_pose(angles)
    n_legs = 8;
    segment_lengths = [1.2, 0.7, 1.0];
    a = 1.5; b = 1.0;
    left_leg_angles = deg2rad([45, 75, 105, 135]);
    right_leg_angles = deg2rad([-135, -105, -75, -45]);
    base_angles = [left_leg_angles, right_leg_angles];
    leg_labels = {'L1', 'L2', 'L3', 'L4', 'R4', 'R3', 'R2', 'R1'};

    if length(angles) ~= n_legs * 3
        error('Input angles must be a 1x24 vector.');
    end

    figure(gcf); clf;
    set(gcf, 'Color', 'w');
    axis equal;
    grid on;
    hold on;
    xlabel('X'); ylabel('Y'); zlabel('Z');
    view(45, 30);
    xlim([-4 4]); ylim([-4 4]); zlim([-2 2]);

    % body ellipse
    t = linspace(0, 2*pi, 120);
    body_x = a * cos(t);
    body_y = b * sin(t);
    plot3(body_x, body_y, zeros(size(t)), 'k-', 'LineWidth', 3);

    % head marker
    plot3(a + 0.2, 0, 0, 'r^', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

    % loop legs
    for i = 1:n_legs
        idx = (i-1)*3 + 1;
        theta1 = angles(idx);
        theta2 = angles(idx+1);
        theta3 = angles(idx+2);

        % base pos
        angle = base_angles(i);
        x_base = a * cos(angle);
        y_base = b * sin(angle);
        base_pos = [x_base, y_base, 0];

        [j1, j2, j3, j4] = forward_leg_kinematics2(base_pos, angle, [theta1, theta2, theta3], segment_lengths);

        plot3([j1(1), j2(1)], [j1(2), j2(2)], [j1(3), j2(3)], 'k-', 'LineWidth', 2);
        plot3([j2(1), j3(1)], [j2(2), j3(2)], [j2(3), j3(3)], 'b-', 'LineWidth', 2);
        plot3([j3(1), j4(1)], [j3(2), j4(2)], [j3(3), j4(3)], 'r-', 'LineWidth', 2);
        plot3(j4(1), j4(2), j4(3), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');

        offset = 0.2;
        label_pos = base_pos + offset * [cos(angle), sin(angle), 0];
        text(label_pos(1), label_pos(2), label_pos(3)+0.05, leg_labels{i}, 'FontSize', 10, 'FontWeight', 'bold');
    end

    hold off;
end

function [j1, j2, j3, j4] = forward_leg_kinematics2(base_pos, base_angle, joint_angles, segment_lengths)
    theta1 = joint_angles(1); % coxa yaw
    theta2 = joint_angles(2); % femur pitch
    theta3 = joint_angles(3); % tibia pitch

    L1 = segment_lengths(1);
    L2 = segment_lengths(2);
    L3 = segment_lengths(3);

    j1 = base_pos;

    coxa_elevation = deg2rad(30);
    coxa_horiz_dir = [cos(base_angle + theta1), sin(base_angle + theta1), 0];
    rot_axis = cross(coxa_horiz_dir, [0 0 1]);
    if norm(rot_axis) < 1e-8
        rot_axis = [0 1 0];
    end
    R = axis_angle_rotation_matrix(rot_axis, coxa_elevation);
    coxa_dir = (R * coxa_horiz_dir')';

    j2 = j1 + L1 * coxa_dir;

    femur_rot_axis = cross(coxa_dir, [0 0 1]);
    if norm(femur_rot_axis) < 1e-8
        femur_rot_axis = [0 1 0];
    end
    femur_rot_axis = femur_rot_axis / norm(femur_rot_axis);
    femur_dir = rotate_vector(coxa_dir, femur_rot_axis, theta2);

    j3 = j2 + L2 * femur_dir;

    tibia_rot_axis = cross(femur_dir, [0 0 1]);
    if norm(tibia_rot_axis) < 1e-8
        tibia_rot_axis = [0 1 0];
    end
    tibia_rot_axis = tibia_rot_axis / norm(tibia_rot_axis);
    tibia_dir = rotate_vector(femur_dir, tibia_rot_axis, theta3);

    j4 = j3 + L3 * tibia_dir;
end

function R = axis_angle_rotation_matrix(axis, angle)
    axis = axis / norm(axis);
    x = axis(1); y = axis(2); z = axis(3);
    c = cos(angle); s = sin(angle); C = 1 - c;
    R = [ x*x*C + c,   x*y*C - z*s, x*z*C + y*s;
          y*x*C + z*s, y*y*C + c,   y*z*C - x*s;
          z*x*C - y*s, z*y*C + x*s, z*z*C + c ];
end

function v_rot = rotate_vector(v, axis, angle)
    R = axis_angle_rotation_matrix(axis, angle);
    v_rot = (R * v')';
end
