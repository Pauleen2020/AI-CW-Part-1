function gaits = generate_gaits(population, NUM_OF_FRAMES)
    gaits = cell(1, length(population));

    for i=1:length(population)
        gaits{i} = generate_gait(population{i}, NUM_OF_FRAMES);
    end
end


function gait = generate_gait(chromsome, NUM_OF_FRAMES)
    gait = zeros(1, NUM_OF_FRAMES);
    INITIAL_FRAME = initial_frame();
    previous_frame = INITIAL_FRAME;

    for i=1:NUM_OF_FRAMES
        frame = generate_frame(chromsome, previous_frame);
        gait(i) = frame;
        previous_frame = frame;
    end
end

function frame = generate_frame(chromosome, previous_frame)
    frame = zeros(1, lenghth(previous_frame));
    for i=1: length(previous_frame)
        temp = 0;
        for j=1; length(chromosome)
            temp = temp + chromosome(j + (i - 1) * length(previous_frame)) * previous_frame(i);
        end
        frame(i) = temp;
    end
end