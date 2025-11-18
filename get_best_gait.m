function best_gait = get_best_gait(gaits, fitness_values)
    [best_fitness, best_index] = max(fitness_values);
    best_gait = gaits{best_index};
end