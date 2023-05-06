%% Xinahoxu@tesla.com
%  Fuelcell Power Slow Drop (FPSD) plot script


% FcOptPwr_fpsd_comp = [FcOptPwr_fpsd_comp,FcOptPwr];
% BattOptPwr_fpsd_comp = [BattOptPwr_fpsd_comp,BattOptPwr];
% BattSocOpt_fpsd_comp = [BattSocOpt_fpsd_comp,BattSocOpt];
% BattSocOfst_fpsd_comp = [BattSocOfst_fpsd_comp,BattSocOfst];
% Hyd_con_rmb_fpsd_comp = [Hyd_con_rmb_fpsd_comp,Hyd_con_rmb];


sidx = 1;
eidx = 7030;


%% plot 1
% figure
% 
% 
% hold on 
% % plot(PS_power_req_kW(sidx:eidx),'k');
% plot(Hyd_con_rmb_fpsd_comp(sidx:eidx,1),'r',LineWidth=1.5);
% plot(Hyd_con_rmb_fpsd_comp(sidx:eidx,2),'b',LineWidth=1.5);
% % plot(tbSoc_ref(sidx:eidx,2),LineWidth=1)
% hold off
% set(gcf,'Position',[347,162,800,220]);
% xlabel('Time (s)','FontName','Times New Roman','FontSize',11);
% ylabel('msg','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
%     
% legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
% legend({'non-FPSD','FPSD'},'location','NorthEast');
% 
% 
% stop
% 
% %% plot 2
% figure
% 
% ssidx = 1820;
% eeidx = 1910;
% 
% hold on
% plot(PS_power_req_kW(ssidx:eeidx),'b');
% plot(FcPwrRef_row(ssidx:eeidx),LineWidth=1.5);
% plot(FcOptPwr(ssidx:eeidx),LineWidth=1.5);
% hold off
% set(gcf,'Position',[347,162,800,220]);
% xlabel('Time (s)','FontName','Times New Roman','FontSize',11);
% ylabel('msg','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
%     
% legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
% legend({'SQP','FPSD'},'location','NorthEast');
% 
% 
% stop


ttDegTable = linspace(0,0.13,50);

delta_pfc_slice = abs(FcOptPwr_fpsd_comp(sidx+1:eidx,:) -...
    FcOptPwr_fpsd_comp(sidx:eidx-1,:));
transient_pfc_slice = interp1(1:50,ttDegTable,delta_pfc_slice);
transient_pfc_slice = delta_pfc_slice .* transient_pfc_slice .* 93*50*usd2rmb/(2*100000);
transient_pfc_slice(isnan(transient_pfc_slice) == 1) = 0;

figure
yyaxis left
hold on
plot(transient_pfc_slice(:,1),'-r',LineWidth=1.5);
plot(transient_pfc_slice(:,2),'-b',LineWidth=1.5);
hold off

yyaxis right
hold on
plot(FcDeg_comp(:,1) + Hyd_con_rmb_fpsd_comp(:,1),'-r',LineWidth=1.5);
plot(FcDeg_comp(:,2) + Hyd_con_rmb_fpsd_comp(:,2),'-b',LineWidth=1.5);
hold off

set(gcf,'Position',[347,162,800,220]);

stop

figure
hold on
plot(FcDeg_comp(:,1) + Hyd_con_rmb_fpsd_comp(:,1),'r',LineWidth=1.5);
plot(FcDeg_comp(:,2) + Hyd_con_rmb_fpsd_comp(:,2),'b',LineWidth=1.5);
hold off
set(gcf,'Position',[347,162,800,220]);


stop
% FPSD lookup table assemble
fpsdtable = [DropStepRef_x,DropStepRef_y];

fpsdtable_plot = ones(10,10);
for i = 1:length(fpsdtable(:,1))
    fpsdtable_plot(i) = fpsdtable(i,2);
end

% FPSD lookup table plot
figure
figure('position',[150,100,700,600]);

bar3(fpsdtable_plot')
set(gca,'yticklabel',{'45.5-50','40.5-45','35.5-40','30.5-35','25.5-30','20.5-25','15.5-20','10.5-15','5.5-10','0.5-5'},'Fontname','Times New Roman','FontSize',11);
set(gca,'xticklabel',{'1','2','3','4','5','6','7','8','9','10'},'Fontname','Times New Roman','FontSize',11);

zlabel('n_d','FontName','Times New Roman','FontSize',16);
ylabel('P_f_c_,_e','FontName','Times New Roman','FontSize',14,'LineWidth',1.5);



