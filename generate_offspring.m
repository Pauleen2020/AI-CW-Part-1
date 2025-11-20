function population = generate_offspring(parents, POPULATION_SIZE, MUTATION_RATE, MAX_MUTATION_ANGLE)
    offspring = {};

    offspring{end+1} = parents{1};

    while length(offspring) < POPULATION_SIZE
        breeding_parents = choose_parents(parents);
        child = crossover(breeding_parents);
        mutated_child = mutate_child(child, MUTATION_RATE, MAX_MUTATION_ANGLE);
        offspring{end+1} = mutated_child;
    end

    population = offspring;
end

function breeding_parents = choose_parents(parents)
    breeding_parents = {
        parents{randi(length(parents))}, parents{randi(length(parents))}
    };
end

function child = crossover(breeding_parents)
    child = zeros(1, length(breeding_parents{1}));

    parent1i = randi(2);

    parent1 = breeding_parents{parent1i};
    parent2 = breeding_parents{3 - parent1i};

    crossover_point = floor(length(parent1) / 2);

    child = [parent1(1:crossover_point), parent2(crossover_point+1:end)];
end

function mutated_child = mutate_child(child, MUTATION_RATE, MAX_MUTATION_ANGLE)
    disp("mutate_child input class: " + class(child));
    mutated_child = child;

    if rand() < MUTATION_RATE
        disp("mutated_child element class: " + class(mutated_child(1)));
        mutation_index = randi(length(child));
        mutation_value = (rand() * 2 - 1) * MAX_MUTATION_ANGLE;
        mutated_child(mutation_index) = mutated_child(mutation_index) + mutation_value;
    end
end
