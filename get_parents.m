function parents = get_parents(population, fitness_values, NUM_OF_SURVIVORS, TOP_SURVIVORS, RANDOM_SPIDERS, INPUT_SIZE, OUTPUT_SIZE)
    ordered_indices = sort_fitness_indices(fitness_values);

    parents = zeros(1, NUM_OF_SURVIVORS);

    % Best performers
    for i=1:TOP_SURVIVORS
        parents(i) = population(ordered_indices(i));
    end

    % Random spiders
    random_spiders = generate_population(RANDOM_SPIDERS, INPUT_SIZE, OUTPUT_SIZE);
    parents = [parents, random_spiders];

end


function ordered_indices = sort_fitness_indices(fitness_values)
    [~, ordered_indices] = sort(fitness_values, 'descend');
end