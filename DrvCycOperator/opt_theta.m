function [theta0,theta1] = opt_theta(data, prop)
%     global tom_0122to0125
%     theta0 = interp1(tom_0122to0125(2:20,1),tom_0122to0125(2:20,2),prop);
%     theta1 = interp1(tom_0122to0125(2:20,1),tom_0122to0125(2:20,3),prop);
    theta0 = interp1(data(2:20,1),data(2:20,2),prop);
    theta1 = interp1(data(2:20,1),data(2:20,3),prop);
end