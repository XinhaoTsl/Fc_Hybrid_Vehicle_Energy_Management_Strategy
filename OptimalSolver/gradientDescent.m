function [theta, J_history] = gradientDescent(X, y, theta, alpha, num_iters)

    m = length(y); 
    % 样本数量
    
    J_history = zeros(num_iters, 1);
    % 记录J最优化的过程，(1500,1),all elements is zero
    
    for iter = 1:num_iters
        H = X * theta;
        %(97,2)*(2*1)=(97,1)
        T = [0 ; 0];
        %(2,1)，记录梯度
    
        for i = 1 : m
            T = T + (H(i) - y(i)) * X(i,:)';    
            % (1,1)*(1*2)的转置，结果为（2，1）
        end
    
        theta = theta - (alpha * T) / m;
    
        J_history(iter) = computeCost(X, y, theta);
        % theta带入，调用损失函数，计算损失，并记录在J_history中
    
    end
end
