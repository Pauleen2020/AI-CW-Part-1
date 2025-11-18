function population = generate_population(POPULATION_SIZE, INPUT_SIZE, OUTPUT_SIZE)
    population = zeros(1, POPULATION_SIZE);

    for i = 1:POPULATION_SIZE
        population(i) = generate_spider(INPUT_SIZE, OUTPUT_SIZE);
    end
end