-- This File contains all explanations for choices made --

-- GA --

Our Genetic Algorithm evolves the movement of a spider, aiming for a stable and effective moving gait.

--Chromosome Encoding
The chromosome is a 1x48 vector. These represent the weights for the spider's 24 joints (2 weights per joint - one for the previous angle's influence, one for a bias).

--Fitness Function
We designed the fitness function to reward continuous movement and penalize various mistakes. This is to prevent the GA from finding the safe solution of just not moving at all.
- Rewards:
    - `MOVEMENT_SCALAR`: The main reward for moving the feet along the X-axis (forwards or backwards).
    - `BAND_REWARD_SCALAR`: Rewards feet that are in a stable "stance" position on the ground. This also helps with prevented illegial joint positions.
- Penalties:
    - `LOW_MOVEMENT_PENALTY_SCALAR`: A large penalty to prevent the spider from "freezing" in place, which was a major problem initially.
    - `PENETRATION_SCALAR`: Applys a penalty for any feet that go through the floor.
    - `VARIANCE_SCALAR`: Penalizes body wobbling by checking the height consistency of supporting feet.
    - `OVERLAPPING_LEGS_FITNESS_SCALAR`: To prevent collisions, a penalty is applied when any joints exceed the angular limits defined.
    - `ANGLE_CHANGE_SCALAR`: To encourge smoother movements, this punishes if a joint changes angle by a significant amount.

--Select Parents
For selecting parents we decided to use a mix of Elitism and Random Survivor selection. Our use of Elitism keeps the 16 best gaits around while we also then use random selection for 4 gaits, resulting in a total of 20.
This allows us to preserve the best solutions whilst also keeping a good variety to attempt to prevent stagnation.
We then use a single point crossover breed function which picks two parent from the 20 survivors listed above. The child generated uses the first half from one parents chromosome and the second half from the other. This is carried to the next generation alongside the best spider.
After crossover, each gene in the new chromosome has a chance to be mutated, defined by the mutation rate of the function. If a gene is selected, a small random value is added. This can add traits such as phase shifts and changes in amplitude.

--Gait Generation
The chromosome's weights to generate a frame. for each joint we look at the previous angle of a joint, multiplies it by a weight, adds a bias (the second weight), and this gives the desired change in angle for the next frame. This is done  for 300 frames to create the full gait.

--Performance Visualization
A graph is included, this shows the best fitness score per generation, which helps see if the GA is learning.
 The final best gait that is generated is then saved as a 3D animation for playback purposes (`best_spider_gait.mp4`). This plays all the frames at a variable framerate. 
 The graph is also saved as the first frame of the animation as a way to refer back to it.

--Problems Faced & Fixes
At first, the GA suffered an issue where it would stop moving after a few generations. This is because the GA would learn that it would not recieve any punishments by not moving, while not recieving any less reward.
To prevent this issue from occuring, we added a heavy punishment if no legs moved while also added a large reward for any movement occuring, effectively telling the GA that it had to make movements.
We also at first set no hard limits to movement and angle limits, expecting the GA to learn them itself, however we then found that the angles would experience exponential growth into the billions. While these still would result in technically valid angles it was above the limit we were expecting.
This meant that we had to add hard limits to the angle change per frame and joint angle limits.
The final major problem we had was that by using random surivor selection, we would end up with chaotic, invalid results too frequently.
Therefore we changed it to select random survivors from the existing, less-fit population pool, which keeps the diversity but within a more stable set of genes.

--Still Existant Problems
- The minimum specified number of moving legs are also not alternating, in which the thoery is flawed in the fact that it hasn't got any fucntion to alternate the legs to their adjacent legs, making the movement look unnatural
- The GA generations are very slow, 1000 generations took about 1.5 hours to generate. This is likely due to some variables changing size every iteration which heavily reduces efficiency.
- The GA hasn't really taken "stability" into account. This can end up with it having leg positions that independently are valid but may not be a stable standing position for the spider when the context of all 8 legs are taken into account.

---
-- NN --

The Neural Network learns to imitate the best gait produced by the GA. It learns to predict the next frame of the gait given the current one.

--Neural Network Architecture
We have selected for 24 neurons (vector) to be the input and 24 neurons to be the output, as the NN is directly predicting a frame of the gait. 48 hidden layers are used to prevent overfitting while having enough space to capture any non-linear dependencies.
The NN does not use the entire gait as the input to prevent it from being very hardware intensive and slow whilst not giving a different/better result compared to us just giving the current frame and the next frame.
The way we decided to make the NN work is by taking the current frame as the input 24 neurons and the setting a target frame for the NN to try and reach, being the next frame in the gait. It then tries its best to predict this frame accurately via our methods below.

--Activation and Loss Functions
For the activation function chosen, we experimented with all four but settled with leaky RELU via trial and error. 
Sigmoid was tried first, but the NN would quickly stop adjustintg and would collapse to a constant output for all 300 frames.
Tanh was a slight improvement, but like sigmoid it still saturates, in this case it would flip between +- 1. For sequential mapping, we require smooth transitions while the NN would learn trivial attractors too easily.
Plain Relu would also repeat a constant output like Sigmoid. This is because any negative input would be killed by RELU due to any negative input outputting 0. This killed most frames, forcing a constant output.
Leaky RELU works best as it outputs a small negative value for negative inputs, unlike Plain RELU which outputs 0. Neurons don't instantly die if there is a negative output so this allowed the NN to actually get a solution that was not alternating or constant.
The loss function being used here is MSE (Mean Squared Error) which measures the average square difference between the predicted and the actual frame within the gait. 
MSE ensures that large deviations from the actual frame are punished more, which allows the MSE to get smaller overtime which reflects how close the NN is to being accurate to the actual gait given.

--Training Method & Learning Rate
Stochastic Gradient Descent (SGD) with a batch size of 1 is being used here. The training frames are shuffled each epoch, and the network learns from each frame-to-frame transition one by one.
Learning Rate: Tuned to 0.008. We didn't see that much of a difference between other values like 0.005 and 0.001 however.

--Backpropagation and Convergence
The backpropagation algorithm calculates the vector error and works backward to figure out how much each weight should be adjusted. The MSE reducing over time shows that the convergence is functioning.
--Data Handling
The network uses the `bestGait.mat` file produced by the GA. as the input.
The 300x24 gait matrix is broken down into pairs being the current frame and the next frame. These are the only two parts of data being handled by the NN at a time to reduce the hardware load.

--Performance Visualization
Just like the GA, we save a video (best_spider_gait_NN.mp4) which saves the video of the final gait produced by the NN for playback.
We also generate a graph to show training progress like the GA by plotting the MSE vs epochs. Also like the GA video it is saved as the first frame of the playback.

--Comparison with Libraries
This entire project was built from scratch using only core MATLAB. No toolboxes like the Deep Learning Toolbox were used.