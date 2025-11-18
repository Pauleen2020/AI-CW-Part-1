%-------------Parameters-------------%
numOfIndividuals = 300;
minAngle = -pi/4;
maxAngle = pi/4;



%-------------Variables-------------%

% Population of numOfIndividuals X 24, with the genes within the range of
% min/maxAngle
population = minAngle + (maxAngle - minAngle) * rand(numOfIndividuals, 24);

%print population
population;

%-------------Generations-------------%

% for Loop for the generations go here

    % Fitness function to define the ranking of each individual in population
    % fitness(population, ...)
    
    
    
    % seclection of parents to breed
    % select_parents(population, fitness_outcome?)
    
    
    
    % Crossover and generating new children to make up the full population
    % generate_offsprint(parents)
    
    
    
    % mutation of the population
    % mutate_offspring(..)

% end generation for loop + some print functions here to show progress?



%-------------Create .mp4 file for fast playback-------------%

% Loop though all the vectors in the final gait and save to a file for faster
% playback (30fps)
% save_spider_gait_video(population, 'spider_gait.mp4', 30);

% can choose whether to render live and see it instead of saving the video
% (unsupported in browser)
spider_gait(population)




function init_ga_spider()
    POPULATION_SIZE= 100;
    SPIDER_INPUT_SIZE = 24;
    SPIDER_OUTPUT_SIZE = 24;
    GENERATIONS = 100;

    NUM_OF_SURVIVORS = 20;
    TOP_SURVIVORS = 16;
    RANDOM_SPIDERS = 4;

    MUTATION_RATE = 0.001;
    MAX_MUTATION_ANGLE = 0.05;


    TRAINING_FRAMES = 100;
    GAIT_FRAMES = 300;



    population = generate_population(POPULATION_NUM, SPIDER_INPUT_SIZE, SPIDER_OUTPUT_SIZE);


    for i=1:GENERATIONS
        gaits = generate_gaits(population, TRAINING_FRAMES);

        fitness_values = evaluate_fitness(gaits);

        parents = get_parents(population, fitness_values, NUM_OF_SURVIVORS, TOP_SURVIVORS, RANDOM_SPIDERS, INPUT_SIZE, OUTPUT_SIZE);

        population = generate_offspring(parents, POPULATION_SIZE, MUTATION_RATE, MAX_MUTATION_ANGLE);
    end

end