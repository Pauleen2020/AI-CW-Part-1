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

% some Loop for the generations go here

    % Fitness function to define the ranking of each individual in population
    % fitness(population, ...)
    
    
    
    % seclection of parents to breed
    % select_parents(population, fitness_outcome?)
    
    
    
    % Crossover of the parents?
    % generate_offsprint(parents)
    
    
    
    % mutation of those parents
    % mutate_offspring(..)

% end generation loop + some print functions here to show progress?



%-------------Create .mp4 file for fast playback-------------%

% Loop though all the vectors in the final gait and save to a file for faster
% playback (30fps)
save_spider_gait_video(population, 'spider_gait.mp4', 30);



