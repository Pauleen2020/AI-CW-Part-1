-- GA --

Our Genetic Algorithm evolves a controller for a spider, aiming for a stable and effective moving gait.

--Chromosome Encoding
The chromosome is a flat vector of 48 numbers. These represent the weights for a simple controller for the spider's 24 joints (2 weights per joint - one for the previous angle's influence, one for a bias). This simple structure works well with crossover and mutation.

--Fitness Function
The fitness function is designed to reward good movement and penalize mistakes.
- Rewards:
    - `MOVEMENT_SCALAR`: The main reward for moving the feet along the X-axis (forwards or backwards).
    - `BAND_REWARD_SCALAR`: Rewards feet that are in a stable "stance" position on the ground.
- Penalties:
    - `LOW_MOVEMENT_PENALTY_SCALAR`: A large penalty to prevent the spider from "freezing" in place, which was a major problem initially.
    - `PENETRATION_SCALAR`: Penalizes feet that go through the floor.
    - `VARIANCE_SCALAR`: Penalizes body wobbling by checking the height consistency of supporting feet.
    - `OVERLAPPING_LEGS_FITNESS_SCALAR`: Penalizes legs that move past their calculated angular limits, preventing collisions.
    - `ANGLE_CHANGE_SCALAR`: Penalizes jerky movements by limiting how fast a joint can change its angle.

--Select Parents
- Method: We use a mix of Elitism and Random Survivor selection.
- Justification: The top 16 spiders are automatically kept (Elitism) to preserve the best solutions. To keep the gene pool diverse and avoid getting stuck, we also select 4 random spiders from the rest of the population. This balances good results with exploring new ones.

--Breed Function
- Crossover: We use a single-point crossover. Two parents are picked randomly from the 20 survivors. The child is made from the first half of one parent's chromosome and the second half of the other's. The single best spider is also carried over to the new generation directly.

--Mutate Function
- Method: After crossover, each gene in the new child's chromosome has a small chance (MUTATION_RATE) to be mutated. A small random value is added to the gene if it's chosen. This is for introducing new traits.

--Gait Generation
The chromosome's weights are used by a simple controller. To generate a frame, the controller looks at the previous angle of a joint, multiplies it by a weight, adds a bias (the second weight), and this gives the desired change in angle for the next frame. This is done for all 24 joints for 300 frames to create the full gait.

--Performance Visualization
- A graph shows the best fitness score per generation, which helps see if the GA is learning. This is saved as the first frame of the video.
- The final best gait is saved as a 3D animation (`best_spider_gait.mp4`).

--Problems Faced & Fixes
- Initial Problem: The GA learned that the best strategy was to not move at all, as this resulted in the fewest penalties.
- Fix: We introduced a large reward for movement (`MOVEMENT_SCALAR`) and a large penalty for standing still (`LOW_MOVEMENT_PENALTY_SCALAR`). This forced the GA to find active, moving solutions.
- Initial Problem: The controller had no limits, leading to exponential growth in joint angles.
- Fix: We added hard clamps on the maximum angle change per frame and absolute joint angle limits.
- Initial Problem: Selecting completely new random spiders for diversity was too chaotic.
- Fix: We changed it to select random survivors from the existing, less-fit population pool, which keeps the diversity but within a more stable set of genes.

--Still Existant Problems
- The minimum specified number of moving legs are also not alternating, in which the thoery is flawed in the fact that it hasn't got any fucntion to alternate the legs to their adjacent legs, making the movement look unnatural
- the angles seem to find a local minimum where the angles chane

---
-- NN --

The Neural Network learns to imitate the best gait produced by the GA. It learns to predict the next frame of the gait given the current one.

--Neural Network Architecture
- Structure: 24-48-48-24. An input layer of 24 neurons, two hidden layers of 48 neurons each, and an output layer of 24 neurons.
- Justification: This is deep enough to learn complex patterns without being too slow or overfitting. The 24 inputs/outputs map directly to the 24 joints in a single frame.

--Activation and Loss Functions
- Activation Function: **Leaky ReLU**.
- Justification: We tried others, but they failed. Sigmoid/Tanh saturated and produced constant outputs. Plain ReLU had "dying neurons" because it kills all negative values. Leaky ReLU was the best choice because it allows a small gradient for negative inputs, keeping the network alive and able to learn smooth sequences.
- Loss Function: **Mean Squared Error (MSE)**.
- Justification: MSE measures the average squared difference between the predicted frame and the target frame. It punishes large errors more, which is effective for getting the network to be accurate.

--Training Method & Learning Rate
- Method: Stochastic Gradient Descent (SGD) with a batch size of 1. The training frames are shuffled each epoch, and the network learns from each frame-to-frame transition one by one.
- Learning Rate: Tuned to **0.005**. This was a good balance between stable convergence and training speed.

--Backpropagation and Convergence
- Implementation: The backpropagation algorithm is implemented from scratch in `Full_NN.m`. It calculates the error and works backward to figure out how much each weight should be adjusted.
- Convergence: The training process works, which is proven by the training loss graph showing the MSE decreasing over time.

--Data Handling
- Input: The network uses the `bestGait.mat` file produced by the GA.
- Training Pairs: The 300x24 gait matrix is broken down into pairs of `(current_frame, next_frame)`. The network learns to predict `next_frame` from `current_frame`.
- Output: After training, the NN generates its own 300-frame gait by feeding its output back to its input iteratively. This is saved as a video (`best_spider_gait_NN.mp4`).

--Performance Visualization
- A graph of the MSE loss vs. epochs is generated to show the training progress. This is saved as the first frame of the NN video.
- The final NN-generated gait is saved as a 3D animation video.

--Comparison with Libraries
- This entire project was built from scratch using only core MATLAB. No toolboxes like the Deep Learning Toolbox were used. This was done to demonstrate a fundamental understanding of how these algorithms work internally.