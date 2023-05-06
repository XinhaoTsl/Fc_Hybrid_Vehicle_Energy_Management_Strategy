
delta_FcOptPwr_list = FcOptPwr_list(2:end,:) - FcOptPwr_list(1:end-1,:);
idx_size = size(delta_FcOptPwr_list);
tcp_size = size(tcp_fine);

delta_FcOptPwr_list_withNeg = abs(delta_FcOptPwr_list);
delta_FcOptPwr_list_withoutNeg = delta_FcOptPwr_list;
delta_FcOptPwr_list_withoutNeg(delta_FcOptPwr_list_withoutNeg<0) = 0;

Fc_tDeg_withoutNeg_Transient_list = interp1(1:50,tDegTable,delta_FcOptPwr_list_withoutNeg);
Fc_tDeg_withoutNeg_Transient_list(isnan(Fc_tDeg_withoutNeg_Transient_list) == 1) = 0;
Fc_tDeg_withoutNeg_Transient_list = delta_FcOptPwr_list_withoutNeg .* ...
    Fc_tDeg_withoutNeg_Transient_list .* 93*50*usd2rmb/(2*100000);

Fc_tDeg_withNeg_Transient_list = interp1(1:50,tDegTable,delta_FcOptPwr_list_withNeg);
Fc_tDeg_withNeg_Transient_list(isnan(Fc_tDeg_withNeg_Transient_list) == 1) = 0;
Fc_tDeg_withNeg_Transient_list = delta_FcOptPwr_list_withNeg .* ...
    Fc_tDeg_withNeg_Transient_list .* 93*50*usd2rmb/(2*100000);


Fc_tDeg_withoutNeg_Transient_mode_list = zeros(tcp_size(1),idx_size(2)+1);
Fc_tDeg_withNeg_Transient_mode_list = zeros(tcp_size(1),idx_size(2)+1);
Fc_tDeg_withoutNeg_Transient_mode_sum_list = zeros(tcp_size(1)+1,idx_size(2)+1);
Fc_tDeg_withNeg_Transient_mode_sum_list = zeros(tcp_size(1)+1,idx_size(2)+1);

for mode = 1:idx_size(2)
    for i = 1:tcp_size(1)
        % Calculation of the proportion of the fuel cell under the global 
        % power request of the driving cycle
        sidx = tcp_fine(i,1);
        eidx = tcp_fine(i,2);

        fc_tDeg_withoutNeg_temp = Fc_tDeg_withoutNeg_Transient_list(sidx:eidx,mode);
        Fc_tDeg_withoutNeg_Transient_mode_list(i,mode) = ...
            mean(fc_tDeg_withoutNeg_temp(fc_tDeg_withoutNeg_temp>0));
        Fc_tDeg_withoutNeg_Transient_mode_sum_list(i,mode) = ...
            sum(fc_tDeg_withoutNeg_temp);

        fc_tDeg_withNeg_temp = Fc_tDeg_withNeg_Transient_list(sidx:eidx,mode);
        Fc_tDeg_withNeg_Transient_mode_list(i,mode) = ...
            mean(fc_tDeg_withNeg_temp(fc_tDeg_withNeg_temp>0));
        Fc_tDeg_withNeg_Transient_mode_sum_list(i,mode) = ...
            sum(fc_tDeg_withNeg_temp);
    end
end

Fc_tDeg_withoutNeg_Transient_mode_list(:,end) = tcp_fine(:,5);
Fc_tDeg_withNeg_Transient_mode_list(:,end) = tcp_fine(:,5);
Fc_tDeg_withoutNeg_Transient_mode_sum_list(1:tcp_size(1),end) = tcp_fine(:,5);
Fc_tDeg_withNeg_Transient_mode_sum_list(1:tcp_size(1),end) = tcp_fine(:,5);

for mode = 1:idx_size(2)+1
    Fc_tDeg_withoutNeg_Transient_mode_sum_list(tcp_size(1)+1,mode) = ...
        sum(Fc_tDeg_withoutNeg_Transient_mode_sum_list(1:end-1,mode));
    Fc_tDeg_withNeg_Transient_mode_sum_list(tcp_size(1)+1,mode) = ...
        sum(Fc_tDeg_withNeg_Transient_mode_sum_list(1:end-1,mode));
end


%% bar plottomg part
% hw_tDeg_ave = Fc_tDeg_withoutNeg_Transient_mode_list...
%     (Fc_tDeg_withoutNeg_Transient_mode_list(:,idx_size(2)+1) == 3,1:idx_size(2));
% figure
% bar(hw_tDeg_ave)

% The aaccumulationvalue of the Fuel Cell deg cost of each operation mode
fc_Deg_sumval_pre_mode = zeros(3,idx_size(2));
for ridx = 1:3
    for mode = 1:idx_size(2)
        fc_Deg_sumval_pre_mode(ridx,mode) = sum(Fc_tDeg_withoutNeg_Transient_mode_sum_list...
            (Fc_tDeg_withoutNeg_Transient_mode_sum_list(:,end) == ridx,mode));
    end
end
fc_Deg_sumval_pre_mode = fc_Deg_sumval_pre_mode';


%% Horizon bar plot
%  Comparation for fuel cell deg prop of each drive mode
figure
barh(fc_Deg_sumval_pre_mode,'stacked')
set(gcf,'Position',[347,162,800,220]);

set(gca, 'Box', 'off', ...                                   
         'LineWidth',1,...                                   
         'XGrid', 'on', 'YGrid', 'off', ...                   
         'TickDir', 'out', 'TickLength', [.015 .015], ...     
         'XMinorTick', 'off', 'YMinorTick', 'off', ...           
         'XColor', [.1 .1 .1],  'YColor', [.1 .1 .1],...       
         'XScale','linear','YScale','linear',...                  
         'YDir','reverse',...
         'YTick',1:4,...
         'YLim',[0,5],...
         'Yticklabel',{'ECMS','CDCS','Liner','theta'}) 

fc_Deg_prop_pre_mode = zeros(size(fc_Deg_sumval_pre_mode));
for mode = 1:4
    for type = 1:3
        fc_Deg_prop_pre_mode(mode,type) =...
            fc_Deg_sumval_pre_mode(mode,type)/sum(fc_Deg_sumval_pre_mode(mode,:));
    end
end


%% bar plot
%  average deg transient value of each hw mode

hw_tDeg_sum = Fc_tDeg_withoutNeg_Transient_mode_sum_list...
    (Fc_tDeg_withoutNeg_Transient_mode_sum_list(:,idx_size(2)+1) == 3,1:idx_size(2));
vave_regarding = tcp_fine(tcp_fine(:,5) == 3,4);

figure
yyaxis left
bar(hw_tDeg_sum)

yyaxis right
plot(vave_regarding,'-rs','LineWidth',3, 'MarkerEdgeColor','k','MarkerFaceColor',[1,1,1])

set(gcf,'Position',[347,162,360,280]);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'theta-based', 'liner-based', 'CDCS-based', 'ECMS-based'},'location','NorthEast');


%% Traj plot
%  COmparation of the transient value of the whole driving cycle
figure
yyaxis left
hold on
for mode = 1:idx_size(2)
    plot(Fc_tDeg_withoutNeg_Transient_list(:,mode))
end
hold off

yyaxis right
Fc_tDeg_withoutNeg_Transient_traj = zeros(size(Fc_tDeg_withoutNeg_Transient_list));
for i = 2:size(Fc_tDeg_withoutNeg_Transient_list)
    Fc_tDeg_withoutNeg_Transient_traj(i,:) = Fc_tDeg_withoutNeg_Transient_list(i,:) ...
        + Fc_tDeg_withoutNeg_Transient_traj(i-1,:);
end

hold on
for mode = 1:idx_size(2)
    plot(Fc_tDeg_withoutNeg_Transient_traj(:,mode),LineWidth=2)
end

set(gcf,'Position',[347,162,800,220]);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend({'theta-based', 'liner-based', 'CDCS-based', 'ECMS-based'},'location','NorthEast');

