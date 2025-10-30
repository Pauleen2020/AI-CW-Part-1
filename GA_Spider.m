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


% some Loop for the generations go here


% Fitness function to define the ranking of each individual in population
% fitness(population, )


% seclection of parents to breed


% Crossover of the parents?


% mutation of those parents



% Loop though all the vectors in the final gait and save to a file for faster
% playback (30fps)
save_spider_gait_video(population, 'spider_gait.mp4', 30);



