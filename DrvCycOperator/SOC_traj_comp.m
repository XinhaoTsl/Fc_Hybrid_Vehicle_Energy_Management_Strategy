% load SOC_traj_theta_based_soc_traj_comp_CYC_Combined_kmph.mat
load SOC_traj_theta_based_soc_traj_comp_CYC_TU_kmph.mat

figure
yyaxis left
plot(DrvCycKph(:,2), '-b', LineWidth=1)
ylabel('Speed (km/h)','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);

yyaxis right
hold on
plot(SOC_traj, '-g', LineWidth=2)
plot(tbSoc_ref,'-r', LineWidth=1.5)
ylabel('SOC','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);

xlabel('Time (s)','FontName','Times New Roman','FontSize',11);

set(gcf,'Position',[347,162,800,220]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
legend('FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
legend({'Vehicle speed', 'DP-based SOC', 'theta-based SOC'},'location','NorthEast');


