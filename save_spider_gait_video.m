function save_spider_gait_video(gait, filename, frameRate, graph_handle)
    % gait: 300x24 matrix of joint angles
    % filename: name of the output video file (e.g., 'spider_gait.mp4')
    % frameRate: frames per second (e.g., 30)
    % graph_handle: optional handle to a figure to add as the first frame

    v = VideoWriter(filename, 'MPEG-4');  % Create video object
    v.FrameRate = frameRate;
    open(v);  % Open video file for writing

    % Add the graph as the first frame if a handle is provided
    if nargin == 4 && ishandle(graph_handle)
        frameData = getframe(graph_handle);
        writeVideo(v, frameData);
    end

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



