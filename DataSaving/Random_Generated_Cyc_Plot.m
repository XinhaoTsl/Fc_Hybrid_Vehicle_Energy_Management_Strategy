
% for i = 1:20
%     
%     subplot(20,1,i);
%     plot(GeneratedCyc_Msg(:,i));
%     set(gca,'xtick',[],'ytick',[],'xcolor','k','ycolor','k')
%     set(gcf,'Position',[347,162,250,800]);
% end

legend_msg = {'Cycle sets 1-10';'Cycle sets 11-20';'Cycle sets 21-30';'Cycle sets 31-40';'Cycle sets 41-50';'Cycle sets 51-60';'Cycle sets 61-70';'Cycle sets 71-80';'Cycle sets 81-90';'Cycle sets 91-100'};

figure
hold on

for i = 2:11
    plot(Asb_2_ThetaTable(2:20,i),LineWidth=1.5)
end
hold off

%Edit the plot msg here
title_name = 'Theta1 distribution';
xlabel_msg = 'Highway Pattern Proportion';
ylabel_msg = 'theta1';
    
% Operation frame DO NOT CHANGE
title(title_name,'FontName','Times New Roman','FontSize',11);

set(gcf,'Position',[347,162,800,220]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    
xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend(legend_msg,'location','NorthEast');


figure
hold on

for i = 2:11
    plot(Asb_1_ThetaTable(2:20,i),LineWidth=1.5)
end
hold off

%Edit the plot msg here
title_name = 'Theta0 distribution';
xlabel_msg = 'Highway Pattern Proportion';
ylabel_msg = 'theta0';
    
% Operation frame DO NOT CHANGE
title(title_name,'FontName','Times New Roman','FontSize',11);

set(gcf,'Position',[347,162,800,220]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    
xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend(legend_msg,'location','NorthEast');
