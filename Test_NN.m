% Generate training data
training_inputs = rand(1000, 2) / 2;
targets = training_inputs(:, 1) .* training_inputs(:, 2);

% Create and train the neural network
nn = Full_NN(2, [5, 5], 1);
nn = nn.train_nn(training_inputs, targets, 1000, 0.8);

% Test the network
input = [0.3, 0.2];
target = 0.06;
[nn, NN_output] = nn.FF(input);

% Display results
fprintf('\n=============== Testing the Network Screen Output ===============\n');
fprintf('Test input is [%f, %f]\n', input(1), input(2));
fprintf('Target output is %f\n', target);
fprintf('Neural Network actual output is %f, error is %f\n', NN_output, target - NN_output);

fprintf('=================================================================\n');
disp('Final Weights:');
fprintf('\n================= Final Weights =================\n');
for i = 1:length(nn.W)
    fprintf('Weights between Layer %d and Layer %d:\n', i, i+1);
    disp(nn.W{i});
end
fprintf('=================================================\n');

