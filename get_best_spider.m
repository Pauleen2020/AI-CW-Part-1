function best_spider = get_best_spider(population, fitness_values)
    % Find the index of the best fitness value
    [~, best_index] = max(fitness_values);
    
    % Retrieve the best spider from the population
    best_spider = population{best_index};
end