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
save_spider_gait_video(population, 'spider_gait.mp4', 30);



