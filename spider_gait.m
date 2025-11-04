function spider_gait(gait)

    numFrames = size(gait, 1);

    for frame = 1:numFrames
        angles = gait(frame, :);
        plot_spider_pose(angles);  % Your existing plot function
        title(sprintf('Spider Gait - Frame %d of %d', frame, numFrames));
        drawnow;
    end
end