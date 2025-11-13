function population = generate_population(POPULATION_SIZE)
    population = zeros(1, POPULATION_SIZE);

    for i = 1:POPULATION_SIZE
        population(i) = generate_spider();
    end
end