function spider = generate_spider(INPUT_SIZE, OUTPUT_SIZE)

    MIN_GENE_VALUE = -1;
    MAX_GENE_VALUE = 1;
    MIN_STEP_VALUE = 0.01;

    chromosome = generate_chromosome(INPUT_SIZE, OUTPUT_SIZE, MIN_GENE_VALUE, MAX_GENE_VALUE, MIN_STEP_VALUE);
    spider = chromosome;
end




% Generate a chromosome with specified parameters
function chromosome = generate_chromosome(INPUT_SIZE, OUTPUT_SIZE, MIN_GENE_VALUE, MAX_GENE_VALUE, MIN_STEP_VALUE)
    chromosome = zeros(1, INPUT_SIZE * OUTPUT_SIZE);
    for i=1:length(chromosome)
        gene = MIN_GENE_VALUE + (MAX_GENE_VALUE - MIN_GENE_VALUE) * rand();
        chromosome(i) = round(gene / MIN_STEP_VALUE) * MIN_STEP_VALUE;
    end
end