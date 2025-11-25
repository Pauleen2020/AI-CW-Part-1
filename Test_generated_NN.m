numOfIndividuals = 300;
minAngle = -pi/4;
maxAngle = pi/4;
nn = Full_NN(24, [48, 48], 24);
% temporary gait
%population = minAngle + (maxAngle - minAngle) * rand(numOfIndividuals, 24);
%gait = 2 * (population- min(population(:))) / (max(population(:)) - min(population(:))) - 1;
gait = load('bestGait.mat');
epochs = 5000;       
lr = 0.01;
errors = zeros(epochs,1);

% ================== Training ==================
for e = 1:epochs
    S_errors = 0;
    idx = randperm(size(gait,1)-1);
    for i = idx
        input  = gait(i, :);
        target = gait(i+1, :);

        [nn, output] = nn.FF(input);

        % Calc error
        e_vec = target - output;

        % Backpropagation + Gradient Descent
        nn = nn.BP(e_vec);
        nn = nn.GD(lr);

        % Accumulate error
        S_errors = S_errors + nn.msqe(target, output);


    end
    % for graph
    errors(e) = S_errors / (size(gait,1)-1);
    % Print average error per epoch
    fprintf('Epoch %d/%d, Mean Squared Error: %.6f\n', e, epochs, errors(e));
end
% ================= Plotting ==================
figure;
plot(1:epochs, errors, 'LineWidth', 2);
xlabel('Epoch');
ylabel('Mean Squared Error');
title('NN Training Graph');
grid on;
% ================== Testing ==================
k = 1;
if k < size(gait,1)
    input  = gait(k, :);
    target = gait(k+1, :);

    [nn, NN_output] = nn.FF(input);

    fprintf('\n=============== Testing the Network ===============\n');
    fprintf('Test input row %d\n', k);
    fprintf('Target output row %d\n', k+1);
    fprintf('Neural Network output (first 5 values):\n');
    disp(NN_output(1:5));
    fprintf('Error (first 5 values):\n');
    result = target - NN_output;
    disp(result(1:5));
    fprintf('===================================================\n');
else
    disp('Reached the last frame, no target available.');
end
% Generate NN outputs for the whole gait sequence
NN_results = zeros(size(gait));
for i = 1:(size(gait,1)-1)
    [nn, NN_results(i,:)] = nn.FF(gait(i,:));
end

% Visualize the NN-generated gait
% spider_gait(NN_results);
save_spider_gait_video(NN_results, 'best_spider_gait_NN.mp4', 30);