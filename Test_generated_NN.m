
nn = Full_NN(24, [48, 48], 24); 
gait = rand(300,24);
epochs = 1000;       
lr = 0.8;         

% ================== Training ==================
for e = 1:epochs
    S_errors = 0;
    
    % Sequential training: row i -> input, row i+1 -> target
    for i = 1:(size(gait,1)-1)
        input  = gait(i, :);       % Current row (1x24 vector)
        target = gait(i+1, :);     % Next row (1x24 vector)

        % Forward pass
        [nn, output] = nn.FF(input);

        % Calc error
        e_vec = target - output;

        % Backpropagation + Gradient Descent
        nn = nn.BP(e_vec);
        nn = nn.GD(lr);

        % Accumulate error
        S_errors = S_errors + nn.msqe(target, output);
    end
    
    % Print average error per epoch
    fprintf('Epoch %d/%d, Mean Squared Error: %.6f\n', e, epochs, S_errors / (size(gait,1)-1));
end

% ================== Testing ==================
k = 1;
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
