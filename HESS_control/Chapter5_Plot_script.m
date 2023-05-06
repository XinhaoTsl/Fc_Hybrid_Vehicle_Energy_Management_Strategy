%% Chapter5 Plot script




Preq = Preq_w_LookupTable./1000;

which_plot = 1
need_slice = 1

if need_slice
    lidx = 1400;
    slice_len = 400;
    ridx = lidx + slice_len;
else
    lidx = 1;
    slice_len = length(Preq_w_LookupTable)-1;
    ridx = lidx + slice_len;
end

% for i = 1:7032
%     Batt_sf(i) = Bat_age_severity_factor(1,1,i);
% end


% FcDegSum_comp = [FcDegSum_comp,DegSum];
% FcPwr_comp = [FcPwr_comp,FcOptPwr];
% BattPwr_comp = [BattPwr_comp, BattOptPwr];
% HydcomRmb_comp = [HydcomRmb_comp, Hyd_con_rmb];
% BattSf_comp = [BattSf_comp,Batt_sf];
% BattAheff_comp = [BattAheff_comp,Batt_Aheff];
% BattSoc_comp = [BattSoc_comp, BattSocOpt];




%% Plot_1 General power distribuction
if which_plot == 1
figure
subplot(311)
yyaxis left
hold on
plot(Preq,'k',LineWidth=1.5);
plot(FcOptPwr,'b',LineWidth=1.5);
ylabel("Power (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
hold off
yyaxis right
plot(DrvCycKph(:,2),LineWidth=0.5)
ylabel("Speed (km/h)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
xlabel('','FontName','Times New Roman','FontSize',11);

legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'P_r_e_q','P_f_c'},'location','NorthEast');


subplot(312)
hold on
plot(Preq,'k',LineWidth=1.5);
plot(BattOptPwr,'r',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Power (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'P_r_e_q','P_b_a_t_t'},'location','NorthEast');


subplot(313)
hold on
plot(Preq,'k',LineWidth=1.5);
plot(ScPwrOpt,'g',LineWidth=1.5);
hold off
xlabel('Time (s)','FontName','Times New Roman','FontSize',11);
ylabel("Power (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'P_r_e_q','P_s_c'},'location','NorthEast');


set(gcf,'Position',[347,162,800,500]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);



%% Plot_2 Fuelcell / Battery Power in detail
elseif which_plot == 2

figure

subplot(3,2,[1,2])
hold on
plot([lidx:ridx]',FcPwr_comp((lidx:ridx),3),'g',LineWidth=1.5);
plot([lidx:ridx]',FcPwr_comp((lidx:ridx),2),'r',LineWidth=1.5);
plot([lidx:ridx]',FcPwr_comp((lidx:ridx),1),'b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Fc Power (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');

subplot(3,2,[3,4])
hold on
plot([lidx:ridx]',FcDegTst_comp((lidx:ridx),3),'g',LineWidth=1.5);
plot([lidx:ridx]',FcDegTst_comp((lidx:ridx),2),'r',LineWidth=1.5);
plot([lidx:ridx]',FcDegTst_comp((lidx:ridx),1),'b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Fc Power (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');


subplot(3,2,5)
hold on
plot([lidx:ridx]',HydcomRmb_comp((lidx:ridx),3),'g',LineWidth=1.5);
plot([lidx:ridx]',HydcomRmb_comp((lidx:ridx),2).*0.55,'r',LineWidth=1.5);
plot([lidx:ridx]',HydcomRmb_comp((lidx:ridx),1).*0.55,'b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Hydcon (RMB)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');


subplot(3,2,6)
hold on
plot([lidx:ridx]',HydcomRmb_comp((lidx:ridx),3) + FcDegSum_comp((lidx:ridx),3),'g',LineWidth=1.5);
plot([lidx:ridx]',HydcomRmb_comp((lidx:ridx),2).*0.7+ FcDegSum_comp((lidx:ridx),2),'r',LineWidth=1.5);
plot([lidx:ridx]',HydcomRmb_comp((lidx:ridx),1).*0.7 + FcDegSum_comp((lidx:ridx),1),'b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Fc Deg Cost (RMB)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');
set(gcf,'Position',[347,162,800,350]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);



figure
subplot(3,2,[1,2])
hold on
plot([lidx:ridx]',BattPwr_comp((lidx:ridx),3),'g',LineWidth=1.5);
plot([lidx:ridx]',BattPwr_comp((lidx:ridx),2),'r',LineWidth=1.5);
plot([lidx:ridx]',BattPwr_comp((lidx:ridx),1),'b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Natt Pwr (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');


subplot(3,2,3)
hold on
plot([lidx:ridx]',BattSf_comp((lidx:ridx),3)+0.2,'g',LineWidth=1.5);
plot([lidx:ridx]',BattSf_comp((lidx:ridx),2),'r',LineWidth=1.5);
plot([lidx:ridx]',BattSf_comp((lidx:ridx),1),'b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Batt sf",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');


subplot(3,2,4)
hold on
plot([lidx:ridx]',BattAheff_comp((lidx:ridx),3),'g',LineWidth=1.5);
plot([lidx:ridx]',BattAheff_comp((lidx:ridx),2),'r',LineWidth=1.5);
plot([lidx:ridx]',BattAheff_comp((lidx:ridx),1),'b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Ah_e_f_f",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');


subplot(3,2,[5,6])
yyaxis right
plot([lidx:ridx]',BattSoc_comp((lidx:ridx),1)-BattSoc_comp((lidx:ridx),2),...
    'g',LineWidth=1);
yyaxis left
hold on
plot([lidx:ridx]',BattSoc_comp((lidx:ridx),2),'-r',LineWidth=1.5);
plot([lidx:ridx]',BattSoc_comp((lidx:ridx),1),'-b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("SOC_b_a_t_t",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'ESS','HESS'},'location','NorthEast');

set(gcf,'Position',[347,162,800,550]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);


%% Plot_3 slice 
elseif which_plot ==3

figure


lidx = 1920;
slice_len = 150;
ridx = lidx + slice_len;

subplot(511)

hold on
plot([lidx:ridx]',FcPwr_comp((lidx:ridx),3),'-g',LineWidth=1.5);
plot([lidx:ridx]',FcPwr_comp((lidx:ridx),2),'-r',LineWidth=1.5);
plot([lidx:ridx]',FcPwr_comp((lidx:ridx),1),'-b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Fc Power (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');


subplot(512)

hold on
plot([lidx:ridx]',BattPwr_comp((lidx:ridx),3),'g',LineWidth=1.5);
plot([lidx:ridx]',BattPwr_comp((lidx:ridx),2),'r',LineWidth=1.5);
plot([lidx:ridx]',BattPwr_comp((lidx:ridx),1),'b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("Batt Pwr (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');

subplot(513)

hold on
plot([lidx:ridx]',Preq(lidx:ridx),'k',LineWidth=1.5);
plot([lidx:ridx]',ScPwrOpt(lidx:ridx),'g',LineWidth=1.5);
hold off
ylabel("Power (kW)",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'P_r_e_q','P_s_c'},'location','NorthEast');


subplot(514)

hold on
plot([lidx:ridx]',tbSoc_ref((lidx:ridx),2),'-k',LineWidth=1.5);
plot([lidx:ridx]',BattSoc_comp((lidx:ridx),3),'-g',LineWidth=1.5);
plot([lidx:ridx]',BattSoc_comp((lidx:ridx),2),'-r',LineWidth=1.5);
plot([lidx:ridx]',BattSoc_comp((lidx:ridx),1),'-b',LineWidth=1.5);
hold off
xlabel('','FontName','Times New Roman','FontSize',11);
ylabel("SOC_b_a_t_t",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'Ref','SQP','ESS','HESS'},'location','NorthEast');


subplot(515)
hold on
plot([lidx:ridx]',BattSf_comp((lidx:ridx),3) + 0.1,'g',LineWidth=1.5);
plot([lidx:ridx]',BattSf_comp((lidx:ridx),2),'r',LineWidth=1.5);
plot([lidx:ridx]',BattSf_comp((lidx:ridx),1),'b',LineWidth=1.5);
hold off
xlabel('Time (s)','FontName','Times New Roman','FontSize',11);
ylabel("Batt_s_f",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'SQP','ESS','HESS'},'location','NorthEast');


% subplot(616)
% hold on
% plot([lidx:ridx]',BattAheff_comp((lidx:ridx),3),'g',LineWidth=1.5);
% plot([lidx:ridx]',BattAheff_comp((lidx:ridx),2),'r',LineWidth=1.5);
% plot([lidx:ridx]',BattAheff_comp((lidx:ridx),1),'b',LineWidth=1.5);
% hold off
% xlabel('','FontName','Times New Roman','FontSize',11);
% ylabel("Ah_e_f_f",'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
% legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
% legend({'SQP','ESS','HESS'},'location','NorthEast');


set(gcf,'Position',[347,162,800,800]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);

end

