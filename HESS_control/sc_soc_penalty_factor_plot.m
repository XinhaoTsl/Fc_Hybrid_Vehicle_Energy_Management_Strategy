

% plot_penalty = sc_penalty([0.31:0.01:0.59]', 0.45);
% plot(plot_penalty);


% plot_range = 0.5:0.1:1.8;
% 
% plot_sf_penalty = Batt_penalty(plot_range);
% hold on
% plot(plot_range,plot_sf_penalty)
% plot(plot_range,plot_range)
% hold off


alpha_set = transpose(linspace(0,1,200));
sqp_state = [0.6; 0.4; 0.4; 30];
plot_cost = rwd_est(alpha_set, sqp_state);

figure
hold on
plot(linspace(0,1,200),plot_cost(:,1),'-r',LineWidth=1)
plot(linspace(0,1,200),plot_cost(:,2),'g',LineWidth=1)
plot(linspace(0,1,200),plot_cost(:,3),'b',LineWidth=2)
legend({'Penalty Battery','Penalty Sc','Cost sum'},'location','NorthWest');

[min_penalty_cost,alpha_idx] = min(plot_cost(:,3));

min_penalty_cost
alpha_set(alpha_idx)

hold off

