function save_spider_gait_video(gait, filename, frameRate)
    % gait: 300x24 matrix of joint angles
    % filename: name of the output video file (e.g., 'spider_gait.mp4')
    % frameRate: frames per second (e.g., 30)

    v = VideoWriter(filename, 'MPEG-4');  % Create video object
    v.FrameRate = frameRate;
    open(v);  % Open video file for writing

    numFrames = size(gait, 1);

    for frame = 1:numFrames
        angles = gait(frame, :);
        %disp(angles);
        plot_spider_pose(angles);  % Your existing plot function
        title(sprintf('Spider Gait - Frame %d of %d', frame, numFrames));
        drawnow;

        frameData = getframe(gcf);  % Capture current figure
        writeVideo(v, frameData);   % Write frame to video
    end

    close(v);  % Finalize video file
    fprintf('✅ Video saved to %s\n', filename);
end



