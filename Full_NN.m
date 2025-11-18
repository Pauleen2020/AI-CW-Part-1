classdef Full_NN
    properties
        X      % Number of input neurons
        HL     % Hidden layer sizes
        Y      % Number of output neurons
        L      % Full architecture
        W      % Weights
        B      % Biases
        Der    % Derivatives
        out    % Outputs per layer
    end

    methods
        function obj = Full_NN(X, HL, Y)
            if nargin < 1, X = 2; end
            if nargin < 2, HL = [2, 2]; end
            if nargin < 3, Y = 2; end

            obj.X = X;
            obj.HL = HL;
            obj.Y = Y;
            obj.L = [X, HL, Y];

            % Initialize weights and derivatives
            for i = 1:length(obj.L)-1
                obj.W{i} = rand(obj.L(i), obj.L(i+1));
                obj.Der{i} = zeros(obj.L(i), obj.L(i+1));
            end

            % Initialize outputs
            for i = 1:length(obj.L)
                obj.out{i} = zeros(1, obj.L(i));
            end
            
            for i = 1:length(obj.L) - 1
                obj.W{i} = rand(obj.L(i), obj.L(i+1)) * 0.01;
                b = zeros(1, obj.L(i+1));
                obj.B{i} = b
            end
        end

        function y = leakyrelu(~, x)
            y = max(0.01*x,x);
        end

        function y = leaky_relu_Der(~, x)
            y = ones(size(x))
            y(x<0) = 0.01
        end

        function err = msqe(~, t, output)
            err = mean((t - output).^2);
        end

        function [obj, out] = FF(obj, x)
            obj.out{1} = x;
            out = x;

            for i = 1:length(obj.W)
                out = obj.leakyrelu(out * obj.W{i});
                obj.out{i+1} = out;
            end
        end

        function obj = BP(obj, Er)
            for i = length(obj.Der):-1:1
                out = obj.out{i+1};                          % Output of current layer
                D = Er .* obj.leaky_relu_Der(out);              % Delta
                D_fixed = reshape(D, 1, []);                  % Ensure row vector
        
                this_out = reshape(obj.out{i}, [], 1);        % Ensure column vector
                obj.Der{i} = this_out * D_fixed;              % Outer product
        
                obj.B{i} = obj.B{i} + D_fixed;
                Er = D * obj.W{i}';                           % Propagate error
            end
        end


        function obj = GD(obj, lr)
            for i = 1:length(obj.W)
                obj.W{i} = obj.W{i} + obj.Der{i} * lr;
            end
        end

        function obj = train_nn(obj, x, target, epochs, lr)
            for i = 1:epochs
                S_errors = 0;
                for j = 1:size(x, 1)
                    t = target(j, :);
                    [obj, output] = obj.FF(x(j, :));
                    e = t - output;
                    obj = obj.BP(e);
                    obj = obj.GD(lr);
                    S_errors = S_errors + obj.msqe(t, output);
                end
                fprintf('Epoch %d/%d, Mean Squared Error: %.6f\n', i, epochs, S_errors / size(x, 1));
            end
        end
    end
end
