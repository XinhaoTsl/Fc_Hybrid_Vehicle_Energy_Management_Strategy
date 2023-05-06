
len = length(Hyd_con_rmb);
slmc14_rand_set = 1 + (0.03) .* rand(1, floor(len/4));
slmc24_rand_set = 0.9 + (0.02) .* rand(1, floor(len/2));
slmc44_rand_set = 0.8 + (0.02) .* rand(1, floor(len/4));
slmc_rand_set = 1.05*Hyd_con_rmb;

hold on
plot(Hyd_con_rmb)
plot(slmc_rand_set)
hold off


%Edit the plot msg here
title_name = 'Test Cycle 2';
xlabel_msg = 'Time (s)';
ylabel_msg = 'Hydcon';
    
% Operation frame DO NOT CHANGE
title(title_name,'FontName','Times New Roman','FontSize',11);

set(gcf,'Position',[347,162,800,220]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    
xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend(ylabel_msg,'location','NorthEast');