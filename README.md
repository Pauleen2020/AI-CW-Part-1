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

--explain breed function here

--explain muttae function here


problems faced/theorised, if the weights are 0 what wil happen.
we may need to pass in 1 frame of the gait for the generate_gate function to work

