function population = generate_offspring(parents, POPULATION_SIZE, MUTATION_RATE, MAX_MUTATION_ANGLE)
    offspring = [];

    offspring(end+1) = parents(1);

    while length(offspring) < POPULATION_SIZE
        breeding_parents = choose_parents(parents);
        child = crossover(breeding_parents);
        mutated_child = mutate_child(child, MUTATION_RATE, MAX_MUTATION_ANGLE);
        offspring(end+1) = mutated_child;
    end

    population = offspring;
end

function breeding_parents = choose_parents(parents)
    breading_parents = [
        parents(randi(length(parents))), parents(randi(length(parents)))
    ];
end

function child = crossover(breeding_parents, crossover_point)
    child = zeros(1, length(breeding_parents(1)));

    parent1i = randi(2);

    parent1 = breeding_parents(parent1i);
    parent2 = breeding_parents(3 - parent1i);

    child(1:crossover_point) = parent1(1:crossover_point);
    child(crossover_point+1:end) = parent2(crossover_point+1:end);


end

function mutated_child = mutate_child(child, MUTATION_RATE, MAX_MUTATION_ANGLE)
    mutated_child = child;

    if rand() < MUTATION_RATE
        mutation_index = randi(length(child));
        mutation_value = (rand() * 2 - 1) * MAX_MUTATION_ANGLE;
        mutated_child(mutation_index) = mutated_child(mutation_index) + mutation_value;
    end
end