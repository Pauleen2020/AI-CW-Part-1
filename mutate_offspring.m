function mutated = mutate_offspring(offspring,mutation_rate,gene_min,gene_max)
%MUTATE_OFFSPRING Summary of this function goes here
%   Detailed explanation goes here
% Inputs:
% offspring: a 1x24 vector chromosome
% mutation_rate: probability of mutating each gene
% gene_min/gene_max: lower/upper bounds of each gene
% outputs mutated chromosome (1x24 vector)

%code below is basically a mockup
mutated = offspring;
for i = 1:length(offspring)
    if rand < mutation_rate
        mutated(i) = gene_min + (gene_max - gene_min) * 0.1 * rand;
    end
end