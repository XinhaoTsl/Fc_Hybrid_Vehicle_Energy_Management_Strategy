%% Xinhaoxu@tesla.com

% BattSocOpt_list = [];

% BattSocOpt_list = [BattSocOpt_list, BattSocOpt];
% FcOptPwr_list = [FcOptPwr_list, FcOptPwr];
% BattOptPwr_list = [BattOptPwr_list, BattOptPwr];
% Hyd_con_rmb_list = [Hyd_con_rmb_list, Hyd_con_rmb];


% 1: theta-based; 2: liner SOC; 3: DP; 4: CDCS; 5: ECMS; 

% Cost_list = Cost;
% for i = 2:7031
%     Cost_list(i) = Cost_list(i-1) + Cost_list(i);
% end


figure
for i = 1:length(FcOptPwr_list(1,:))
    hold on
    plot(FcOptPwr_list(6000:6050,i), LineWidth=1)
end
hold off

set(gcf,'Position',[347,162,800,220]);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'theta','liner','CDCS','ECMS'},'location','NorthEast');

% figure
% hold on
% plot(Preq_w_LookupTable./1000,'r',LineWidth=1)
% plot(FcOptPwr_list(:,2),'b',LineWidth=1)

stop

%%%%%%%%%%%% TEMP %%%%%%%%%%%%%%%

% for i = 1:length(tcp_fine(:,1))
%     lidx = tcp_fine(i,1); ridx = tcp_fine(i,2);
%     fc_opt_slt = FcOptPwr_list(FcOptPwr_list(lidx:ridx,mode)>0);
%     fc_req_slt = Preq_w_LookupTable(FcOptPwr_list(lidx:ridx,mode)>0)./1000;
% 
%     tcp_fine(i,7) = mean(fc_opt_slt)/mean(fc_req_slt);
% end

fc_opt_prop_list = zeros(length(tcp_fine(:,1)),length(FcOptPwr_list(1,:)));
fc_opt_acc_list = zeros(length(tcp_fine(:,1)),length(FcOptPwr_list(1,:)));
mode_count = length(FcOptPwr_list(1,:));

for mode = 1:length(FcOptPwr_list(1,:))
    for i = 1:length(tcp_fine(:,1))
        % Calculation of the proportion of the fuel cell under the global 
        % power request of the driving cycle
        sidx = tcp_fine(i,1);
        eidx = tcp_fine(i,2);
        fc_opt_temp = FcOptPwr_list(sidx:eidx,mode);
        fc_req_temp = Preq_w_LookupTable(sidx:eidx)./1000;

        fc_opt_temp_mean = fc_opt_temp(fc_opt_temp >= 2);
        fc_req_temp_mean = fc_req_temp(fc_opt_temp >= 2);

        fc_opt_temp_mean = fc_opt_temp_mean(fc_req_temp_mean > 2);
        fc_req_temp_mean = fc_req_temp_mean(fc_req_temp_mean > 2);

        fc_opt_prop = mean(fc_opt_temp_mean ./ fc_req_temp_mean);
        fc_opt_prop_list(i,mode) = fc_opt_prop;

        % Calculation of the accumulation fuel cost of each control pattern
        % under the highesy driving mode
        
        fc_opt_PwAcc = HydpriceRmb.*sum(interp1(FC_ori_power_kW, ...
            FC_ori_fuel_rate_gps, fc_opt_temp(fc_opt_temp > 0)))./1000;
        fc_opt_acc_list(i,mode) = fc_opt_PwAcc;
    end
end

fc_opt_prop_list(fc_opt_prop_list > 1) = 1;
fc_opt_prop_list(isnan(fc_opt_prop_list) == 1) = 0;
fc_opt_prop_list = [fc_opt_prop_list,tcp_fine(:,5)];
fc_opt_acc_list = [fc_opt_acc_list,tcp_fine(:,5)];

fc_opt_acc_list_temp = zeros(1,length(FcOptPwr_list(1,:))+1);
for mode = 1:length(FcOptPwr_list(1,:))
    fc_opt_acc_list_temp(mode) = sum(fc_opt_acc_list(:,mode));
end
fc_opt_acc_list = [fc_opt_acc_list;fc_opt_acc_list_temp];

fc_opt_acc_list_temp = zeros(1,length(FcOptPwr_list(1,:))+1);
for mode = 1:length(FcOptPwr_list(1,:))
    fc_opt_acc_list_temp(mode) = sum(fc_opt_acc_list(fc_opt_acc_list(:,mode_count+1)==3,mode));
end
fc_opt_acc_list = [fc_opt_acc_list;fc_opt_acc_list_temp];

table_val = zeros(2,length(FcOptPwr_list(1,:)));
for i = 1:length(FcOptPwr_list(1,:))
    table_val(1,i) = mean(fc_opt_prop_list(fc_opt_prop_list(:,mode_count+1) == 3,i));
end


stop
figure

% 
title_name = 'Test Cycle 2';
xlabel_msg = 'Time (s)';
ylabel_msg = 'Speed (m/s)';
    
% Operation frame DO NOT CHANGE
title(title_name,'FontName','Times New Roman','FontSize',11);

% set(gcf,'Position',[347,162,800,220]);
set(gcf,'Position',[347,162,800,220]);

set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    
xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend(ylabel_msg,'location','NorthEast');
