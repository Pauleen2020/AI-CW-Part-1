function parents = get_parents(population, fitness_values, NUM_OF_SURVIVORS, TOP_SURVIVORS, RANDOM_SPIDERS, INPUT_SIZE, OUTPUT_SIZE)
    ordered_indices = sort_fitness_indices(fitness_values);

    parents = {};

    % Best performers (elitism)
    for i = 1:TOP_SURVIVORS
        parents{end+1} = population{ordered_indices(i)};
    end

    % Random survivors chosen from the remaining population to preserve
    % diversity, instead of injecting brand-new random chromosomes.
    remaining_indices = ordered_indices(TOP_SURVIVORS+1:end);
    if ~isempty(remaining_indices)
        n_random = min(RANDOM_SPIDERS, numel(remaining_indices));
        % Replace randsample (Statistics Toolbox) with base MATLAB randperm
        perm = randperm(numel(remaining_indices), n_random);
        rand_sel = remaining_indices(perm);
        for k = 1:numel(rand_sel)
            parents{end+1} = population{rand_sel(k)};
        end
    end

    % If for some reason we still have fewer than NUM_OF_SURVIVORS parents
    % (e.g. very small population), fill up by duplicating best performers.
    while numel(parents) < NUM_OF_SURVIVORS
        parents{end+1} = population{ordered_indices(1)};
    end
end

function ordered_indices = sort_fitness_indices(fitness_values)
    [~, ordered_indices] = sort(fitness_values, 'descend');
end
