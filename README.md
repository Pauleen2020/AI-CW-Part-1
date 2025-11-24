For Notes we are using MIRO

https://miro.com/welcomeonboard/NXdjQURBR3pYdlBScy9rUU1maHJEaUh3WWJXM1pqUFUwamdKUmRRWXZ3YzZqc2VGa0U4aXBsaG0xOG9nbmFwUmFUaHhWOXV3OUg0cnhObWQ1eUsrSWJzWXZCT1JKWndVUEFRNkVVQkhrYUoya281L0g4S3hZampTenlFQnR3V0R0R2lncW1vRmFBVnlLcVJzTmdFdlNRPT0hdjE=?share_link_id=44775794280




-----------------------------
Design Choices

-- GA --
Legs should not touch each other, so we did some angle calculations to determine the boundaries of the base angle (LEGa) and we calculate the number of legs that are intersecting and give a higher fitness value for less intersecting leg.
We initialy set it to 9degrees but we theoretically thogh this was too high so we lowered it to 1. this may chage when we rest tun it

Feet closer to ground get less deductions of fitness

The delta between angles must not be too much so we made a fitness function that evaluates this


Design of GA

Initially we generate a number of chromosomes, which the genes represent a weight.

We loop through these chromosomes and put these through a generate_gait function which we get multiple gaits

these gaits go through a fitness function, of which these will go through a select_parents function

all of these below will change and manipulte the weights/genes,NOT the gaits

-- explain selet parents here
we will take the top 16 and generate 4 completely random spiders to make up 20 spiders

--explain breed function here
we then will breed these 20 to make 100 spiders, breeding will consist of the crossover function among the top 6 parents + two random parents of from the 20 parents.

--explain muttae function here
the mutate function will pick a random gene and change it within a threshold of 5%, a variable is set to dicate the chances that a mutaion happens


problems faced/theorised, if the weights are 0 what wil happen.
we may need to pass in 1 frame of the gait for the generate_gate function to work

We found our approach to the generate_gaits function was flawed because it did not provide any hard constraints at all, meaning exponentially high or low outputs occured.

We scaled each angle by an effective gain, which if it as > 1 then it would lead to exponential growth, <1 would lead to decay to 0

No coupling between joints, no bias term

unaware of max_angle_delta, max_angles, floor and other persistent qualities.

Select Parents were selecting random individuals that were completely randomly generated, of which these could massivly overshoot the rules set in the fitness function and overwhelm the existing best individuals

we also found we should provide rewards not only penalties, we found a local minimum which was for the spider not to move any of its legs as that gave the least penalty. 

Fixes:

Pasing 1 frame of the gait into the generate_gate function to work

Parent Selection: 
random survivors are selected from existing population pool

Offspring/mutation
per child, at most one gene changed, many small changes across the chromosome, bound by max mutation angle.

Motion based reward, joint movement gate and anti freeze penalties, softer constraint penalties were implemented to maintain balenced and consistent movement throughout the gait.

-- NN --
We have chosen to represent the input and output layer to be 24x1. so one set of 24 inputs is one spider frame.
the NN will predict the next frame. We can iterate this to get our 300 frames in a gait.
The other way that could learn and solve the spider problem is by taking every possible value in the gait 300x24, and the NN could learn based on the context of the whole gait. But we realised this would not be feasible due to the hardware requirements necessary, as this would require 7200 inputs and outputs. 
This approach may also be more RAM intensive due to the quantity of numbers being processed at one time.

To train the NN, we take an 'ideal' gait, and take the first frame, pass this into the NN, then train based on the differences to the output and the input + 1, we then take the second frame (2:24) and train based on differences between the output and input(3:24)

For the activation function chosen, we experimented with all four but settled with leaky RELU via trial and error. 
Sigmoid was tried first, but the NN would quickly stop adjustintg and would collapse to a constant output for all 300 frames.
Tanh was a slight improvement, but like sigmoid it still saturates, in this case it would flip between +- 1. For sequential mapping, we require smooth transitions while the NN would learn trivial attractors too easily.
Plain Relu would also repeat a constant output like Sigmoid. This is because any negative input would be killed by RELU due to any negative input outputting 0. This killed most frames, forcing a constant output.
Leaky RELU works best as it outputs a small negative value for negative inputs, unlike Plain RELU which outputs 0. Neurons don't instantly die if there is a negative output so this allowed the NN to actually get a solution that was not alternating or constant.







