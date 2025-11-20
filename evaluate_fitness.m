function fitness_values = evaluate_fitness(gaits)
    fitness_values = zeros(1, length(gaits));

    for i=1: length(gaits)
        fitness_values(i) = evaluate_gait(gaits{i});
    end
end


function gait_fitness = evaluate_gait(gait)
    gait_fitness = 0;

    % Start at 2 cause nothing to compare 1st frame to
    for i=2: length(gait)
        prev_angles = gait{i - 1};
        angles = gait{i};

        fitness = get_fitness(angles, prev_angles);
        gait_fitness = gait_fitness + fitness;
    end
end