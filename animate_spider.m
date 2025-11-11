function animate_spider()
    angles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for i = 1:24
        for ii=0:360
            cla;
            angles(i) = angles(i) + deg2rad(1);
            plot_spider_pose(angles);
            pause(0.05);
        end
        angles(i) = 0;
    end
end