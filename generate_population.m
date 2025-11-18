function population = generate_population(POPULATION_SIZE, INPUT_SIZE, OUTPUT_SIZE)
    population = [];

    for i = 1:POPULATION_SIZE
        population(end+1) = generate_spider(INPUT_SIZE, OUTPUT_SIZE);
    end
end