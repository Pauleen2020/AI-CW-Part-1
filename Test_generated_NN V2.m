% ---------- Minimal gait predictor and rollout ----------
% Settings
epochs      = 5000;          % training epochs
lr          = 0.01;          % learning rate
rolloutSteps = 400;          % number of frames to generate in rollout
seedIndex   = 1;             % which real frame to start the rollout from
videoFile   = 'gait_rollout.mp4';
videoFPS    = 30;

% Load data
data = load('bestGait.mat', 'gait');
gait = data.gait;            % gait is N x 24 (rows = frames, cols = joint angles)

% Build network: 24 inputs -> two hidden layers 48 -> 48 -> 24 outputs
nn = Full_NN(24, [48, 48], 24);

% ---------- One-step training (x_t -> x_{t+1}) ----------
N = size(gait,1);
for epoch = 1:epochs
    perm = randperm(N-1);    % shuffle training pairs
    epochError = 0;
    for i = perm
        x      = gait(i,   :);   % input frame
        target = gait(i+1, :);   % next frame (supervised target)

        [nn, out] = nn.FF(x);    % forward
        err = target - out;      % error vector
        nn = nn.BP(err);         % backpropagate
        nn = nn.GD(lr);          % gradient descent step

        epochError = epochError + nn.msqe(target, out);
    end
    % print average MSE for monitoring
    fprintf('Epoch %d/%d, MSE %.6f\n', epoch, epochs, epochError / (N-1));
end

% ---------- Multistep closed-loop rollout ----------
x = gait(seedIndex, :);               % seed with a real frame
rollout = zeros(rolloutSteps, size(gait,2));
for t = 1:rolloutSteps
    [nn, y] = nn.FF(x);               % predict next frame
    rollout(t, :) = y;                % store prediction
    x = y;                            % feed prediction back as next input
end

% Save rollout video
save_spider_gait_video(rollout, videoFile, videoFPS);
fprintf('Rollout saved to %s (seed %d, steps %d)\n', videoFile, seedIndex, rolloutSteps);
