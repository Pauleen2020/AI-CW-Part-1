function init_ga_spider()

%-------------Variables-------------%
    POPULATION_SIZE= 50;
    SPIDER_INPUT_SIZE = 24;
    SPIDER_OUTPUT_SIZE = 24;
    GENERATIONS = 5;

    NUM_OF_SURVIVORS = 20;
    TOP_SURVIVORS = 16;
    RANDOM_SPIDERS = 4;

    MUTATION_RATE = 0.001;
    MAX_MUTATION_ANGLE = 1;


    TRAINING_FRAMES = 300;
    GAIT_FRAMES = 300;



    population = generate_population(POPULATION_SIZE, SPIDER_INPUT_SIZE, SPIDER_OUTPUT_SIZE);


    for i=1:GENERATIONS
        disp("Generation: " + i);
        gaits = generate_gaits(population, TRAINING_FRAMES);

        fitness_values = evaluate_fitness(gaits);

        parents = get_parents(population, fitness_values, NUM_OF_SURVIVORS, TOP_SURVIVORS, RANDOM_SPIDERS, SPIDER_INPUT_SIZE, SPIDER_OUTPUT_SIZE);

        population = generate_offspring(parents, POPULATION_SIZE, MUTATION_RATE, MAX_MUTATION_ANGLE);
    end

    final_gaits = generate_gaits(population, GAIT_FRAMES);

    final_fitness_values = evaluate_fitness(final_gaits);

    best_gait = cell2mat(get_best_gait(final_gaits, final_fitness_values)');

    best_spider = get_best_spider(population, final_fitness_values);

    %Dipl frames

    

    for frame = 1:GAIT_FRAMES
        angles = best_gait(frame, :);
        disp(angles);
    end

    %disp(best_spider);
    
    %-------------Create .mp4 file for fast playback-------------%

    % Loop though all the vectors in the final gait and save to a file for faster
    % playback (30fps)
    save_spider_gait_video(best_gait, 'best_spider_gait.mp4', 10);
    
    % can choose whether to render live and see it instead of saving the video
    % (unsupported in browser)
    %spider_gait(best_gait)

    save('bestGait.mat', 'best_gait')
end



