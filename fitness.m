function fitness(angles)
    % All stationary feet need to be on the same plane
    % All stationary feet needs to be below the head of the spider
    % Legs cannot interset
    % Each joint needs a maximum delta
    % Each segment should have locked range of motion

    
    MAX_FOOT_HEIGHT = 0;

    MIN_COXA_ANGLE = 0;
    MAX_COXA_ANGLE = 0;
    MAX_COXA_ANGLE_DELTA = 0;

    MIN_FEMUR_ANGLE = 0;
    MAX_FEMUR_ANGLE = 0;
    MAX_FEMUR_ANGLE_DELTA = 0;

    MIN_TIBIA_ANGLE = 0;
    MAX_TIBIA_ANGLE = 0;
    MAX_TIBIA_ANGLE_DELTA = 0;


end