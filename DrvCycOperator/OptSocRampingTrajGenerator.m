%% xinhaoxu@tesla.com
%  Generate the optimal SOC ramping trajectory accordintg to the optimal thetatable
%  Core Dependency of the Main Configuration function

% run Config_c230321.m
load main_theta_results.mat
% global tom_0122to0125

%% Rolling Optimal Parameter Solver
[vstd_formal, vave_formal, a_ave_formal] = Fun_SLMP(DrvCycKph);

len = length(vstd_formal);
updateLen = 50;
ssc = 0;    % SubStepCount
sssc = 0;   % SubStepStopCount
dct = zeros(1,len);
ssVacc = zeros(1,updateLen);
ssVspd = zeros(1,updateLen);


for step = 1:len
    ssc = ssc + 1;

    if step < updateLen
        if max(vave_formal(step)) <= city2sub
            dct(step) = 1; 
        elseif max(vave_formal(step)) <= sub2hw & max(vave_formal(step)) > city2sub
            dct(step) = 2;
        else
            dct(step) = 3;
        end
        ssVacc(ssc) = a_ave_formal(step);
        ssVspd(ssc) = vave_formal(step); 
    else

        if ssc < updateLen
            ssVacc(ssc) = a_ave_formal(step);
            ssVspd(ssc) = vave_formal(step);    % SubStep Vehicle Speed
            if floor(ssVspd(ssc)) == 0          % Vehicle Stop Count
                sssc = sssc + 1; end
            dct(step) = dct(step-1);
    
        elseif ssc == updateLen
            svas = mean(ssVspd);     % Sublevel Vehicle Average Speed (svas)
            
            if step < 2*updateLen
                dct(step) = dct(step-1);

            elseif svas <= city2sub
                if sum(ssVacc>=5)
                    if max(ssVspd) > 1.2*city2sub && floor(min(ssVspd)) == 0
                        dct(step) = 2;
                    elseif sum(ssVspd>city2sub) > updateLen/2
                        dct(step) = 2; 
                    elseif max(ssVspd) < 1.2*city2sub
                        dct(step) = 1;
                    end
                    dct(step) = 1; 
                end
                dct(step) = 1;
    
            elseif svas > city2sub && svas <= sub2hw
                if sum(ssVspd>sub2hw) > updateLen/2
                    if ssVspd(1) >= sub2hw && ssVspd(end) >= sub2hw
                        dct(step) = 3;
                    elseif ssVspd(1) >= sub2hw && svas > 0.8*sub2hw
                        dct(step) = 3;
                    elseif max(ssVspd) > sub2hw*1.2
                        dct(step) = 3;
                    else
                        dct(step) = 2;
                    end
                    dct(step) = 2;
                elseif ssVspd(1) >= sub2hw && ssVspd(end) >= sub2hw
                    dct(step) = 3;
                elseif ssVspd(1) >= sub2hw && svas > 0.8*sub2hw
                    dct(step) = 3;
                else
                    dct(step) = 2;
                end
            else
                dct(step) = 3;
            end

            ssc = 1;
            ssVacc = zeros(1,updateLen);
            ssVspd = zeros(1,updateLen);

            ssVacc(ssc) = a_ave_formal(step);
            ssVspd(ssc) = vave_formal(step);
        end
    end
end

Fixedct = [dct(updateLen:end),dct(end)*ones(1,updateLen-1)];

if SOC_Traj_plot_enable

    figure
    hold on
    
    title('DrvCyc Type','FontName','Times New Roman','FontSize',11);
    xlabel('Drive Step','FontName','Times New Roman','FontSize',11);
    
    yyaxis left
    plot(vave_formal);
    ylabel('Average VehSpd m/s','FontName','Times New Roman','FontSize',11,LineWidth=1.5);

end

%% Ramping Calculation

tcpCount = 1;
tcp = [1, 1, 0, 0, 0];
% tcp = [*CycStratStep, *CycStopStep, CycLen, CycVave]
%               1             2          3       4

for i = 1:length(Fixedct)

    if i < 2
        ;
    elseif i >= 2 
        if abs(Fixedct(i)-Fixedct(i-1)) || i == length(Fixedct)
            tcpCount = tcpCount + 1;    % Cycle Type Conversion Point
            tcp(tcpCount,1) = tcp(tcpCount-1,2);
            tcp(tcpCount,2) = i;
            tcp(tcpCount,3) = tcp(tcpCount,2) - tcp(tcpCount,1);
            tcp(tcpCount,4) = mean(vave_formal(tcp(tcpCount,1):i));
            tcp(tcpCount,5) = Fixedct(1 + floor(mean(tcp(tcpCount,1:2))));
        end
    end
end

lentcp = length(tcp(:,1));

% tcp_fine = [CycStratStep, CycStopStep, Cyclen, CycVave, CycType, SocDropRef]
%                   1            2          3       4        5          6
tcp_fine = zeros(1,5);
tcprow = 1;
tcprow_fine = 0;

while tcprow<= lentcp
    

    if tcp(tcprow,3) > 49
        tcprow_fine = tcprow_fine + 1;
        tcp_fine(tcprow_fine, 1) = tcp(tcprow ,1);
        tcp_fine(tcprow_fine, 2) = tcp(tcprow ,2);
        tcp_fine(tcprow_fine, 3) = tcp(tcprow ,3);
        tcp_fine(tcprow_fine, 4) = tcp(tcprow ,4);
        tcp_fine(tcprow_fine, 5) = tcp(tcprow ,5);

    elseif tcp(tcprow,3) == 49
        % Sudden transient
        if tcp(tcprow+1,3) ~= 49 && tcp(tcprow+1,5) == tcp(tcprow-1,5)
            tcp_fine(tcprow_fine, 2) = tcp(tcprow+1 ,2);
            tcp_fine(tcprow_fine, 3) = tcp_fine(tcprow_fine, 2) - tcp_fine(tcprow_fine, 1);
            tcp_fine(tcprow_fine, 4) = mean(vave_formal(tcp_fine(tcprow_fine, 1):tcp_fine(tcprow_fine, 2)));
            tcprow = tcprow + 1;
        
        % Middle state
        elseif tcp(tcprow+1,3) ~= 49 && tcp(tcprow+1,5) ~= tcp(tcprow-1,5)
            tcprow_fine = tcprow_fine + 1;
            tcp_fine(tcprow_fine, 1) = tcp(tcprow ,1);
            tcp_fine(tcprow_fine, 2) = tcp(tcprow+1 ,2);
            tcp_fine(tcprow_fine, 3) = tcp_fine(tcprow_fine, 2) - tcp_fine(tcprow_fine, 1);
            tcp_fine(tcprow_fine, 4) = mean(vave_formal(tcp_fine(tcprow_fine, 1):tcp_fine(tcprow_fine, 2)));
            tcp_fine(tcprow_fine, 5) = tcp(tcprow+1 ,5);
            tcprow = tcprow + 1;

        % Turbulent
        elseif tcp(tcprow+1,3) == 49
            tblt_count = 1;
            while tcp(tcprow+tblt_count,3) == 49
                tblt_count = tblt_count + 1;
            end

                % Sustain
                if tcp(tcprow+tblt_count,5) == tcp(tcprow-1,5)
                    tcp_fine(tcprow_fine, 2) = tcp(tcprow+tblt_count ,2);
                    tcp_fine(tcprow_fine, 3) = tcp_fine(tcprow_fine, 2) - tcp_fine(tcprow_fine, 1);
                    tcp_fine(tcprow_fine, 4) = mean(vave_formal(tcp_fine(tcprow_fine, 1):tcp_fine(tcprow_fine, 2)));
                    tcprow = tcprow + tblt_count;

                % Drop
                elseif tcp(tcprow+tblt_count,5) ~= tcp(tcprow-1,5)
                    tcp_fine(tcprow_fine, 2) = tcp(tcprow+tblt_count-1 ,2);
                    tcp_fine(tcprow_fine, 3) = tcp_fine(tcprow_fine, 2) - tcp_fine(tcprow_fine, 1);
                    tcp_fine(tcprow_fine, 4) = mean(vave_formal(tcp_fine(tcprow_fine, 1):tcp_fine(tcprow_fine, 2)));
                    tcprow = tcprow + tblt_count-1;
                end

        end
    end
    tcprow = tcprow + 1;
end

if tcp_fine(1,5) == 1 || tcp_fine(1,5) == 2
    if tcp_fine(1,3) < 100 && tcp_fine(2,3) < 1500
        BattSocInitDrop = BattSocInitDrop_rate*sum(tcp_fine(1:2,3));
        tcp_fine(1,5) = 0; tcp_fine(2,5) = 0;
        tcp_fine(2,6) = BattSocInitDrop;
        cyc_build_start_point = 3;
        tbSoc_ref = linspace(BattSocInit, BattSocInit-tcp_fine(2,6), sum(tcp_fine(1:2,3))); 
    else
        BattSocInitDrop = BattSocInitDrop_rate*tcp_fine(1,3);
        tcp_fine(1,5) = 0; tcp_fine(1,6) = BattSocInitDrop;
        cyc_build_start_point = 2;
        tbSoc_ref = linspace(BattSocInit, BattSocInit-tcp_fine(1,6), tcp_fine(1,3)); 
    end
end

opt_DrvPattern = [];
for i = 1:length(tcp_fine())
    opt_DrvPattern = [opt_DrvPattern;tcp_fine(i,5)*ones(tcp_fine(i, 3),1)];
end

if SOC_Traj_plot_enable

yyaxis right
% plot(dct,'r', LineWidth=2);
plot(opt_DrvPattern,'-g', LineWidth=2);
ylabel('DrvCyc Type','FontName','Times New Roman','FontSize',11,LineWidth=1.5);

legend({'VehSpd', 'DrvCyc Type'}, 'Location', 'northeast')

set(gcf,'Position',[347,162,800,220]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);

end

%% SOC Ramping Calculation
cyc_len = sum(tcp_fine(:,3));
hw_len = sum(tcp_fine((tcp_fine(:,5) == 3),3));
hw_prop = hw_len/cyc_len;
[theta0, theta1] = opt_theta(tom_0122to0125, hw_prop);

linerSocDr = (BattSocInit - BattSocLowerLimit)/sum(tcp_fine(:,3));
soc_liner_drop_traj = zeros(cyc_len,1);

hw_vave_list = tcp_fine((tcp_fine(:,5) == 3),4);
hw_vave_list = [ones(length(hw_vave_list),1),hw_vave_list];
k_soc_hw = hw_vave_list*[theta0, theta1]';

% hwSocDr_list = tcp_fine((tcp_fine(:,5) == 3),3).*linerSocDr.*k_soc_hw.*hwSocDr_inc_factor);
% hwSocDr_sum = sum(hwSocDr_list);
% is_hwSocExceed = hwSocDr_sum + BattSocInitDrop > BattSocInit - BattSocLowerLimit;
% tcp_fine((tcp_fine(:,5) == 3),6) = hwSocDr_list;


hwSocDr_sum = sum(tcp_fine((tcp_fine(:,5) == 3),3).*linerSocDr.*k_soc_hw);
is_hwSocExceed = hwSocDr_sum + BattSocInitDrop > BattSocInit - BattSocLowerLimit;
hwSocDr_inc_factor_temp = hwSocDr_inc_factor;

while ~is_hwSocExceed && hwSocDr_inc_factor_temp <=1.55
    hwSocDr_inc_factor_temp = hwSocDr_inc_factor_temp + 0.1;
    hwSocDr_sum_temp = sum(tcp_fine((tcp_fine(:,5) == 3),3).*linerSocDr.*k_soc_hw.*hwSocDr_inc_factor_temp);
    is_hwSocExceed = hwSocDr_sum_temp + BattSocInitDrop > BattSocInit - BattSocLowerLimit;
end


if hwSocDr_inc_factor_temp > 1.1
    hwSocDr_inc_factor = hwSocDr_inc_factor_temp - 0.1;
    hwSocDr_list = tcp_fine((tcp_fine(:,5) == 3),3).*linerSocDr.*k_soc_hw.*hwSocDr_inc_factor;
    hwSocDr_sum = sum(hwSocDr_list);
    tcp_fine((tcp_fine(:,5) == 3),6) = hwSocDr_list;
else
    hwSocDr_list = tcp_fine((tcp_fine(:,5) == 3),3).*linerSocDr.*k_soc_hw.*hwSocDr_inc_factor;
    tcp_fine((tcp_fine(:,5) == 3),6) = hwSocDr_list;
end


if ~is_hwSocExceed
    subSocDr_sum = BattSocInit - BattSocLowerLimit - hwSocDr_sum - BattSocInitDrop;
    sub_prop = tcp_fine((tcp_fine(:,5) == 2),3)./sum(tcp_fine((tcp_fine(:,5) == 2),3));
    subSocDr_list = subSocDr_sum.*sub_prop;
    tcp_fine((tcp_fine(:,5) == 2),6) = subSocDr_list;
elseif is_hwSocExceed
    citySocNegDr_sum = BattSocInit - BattSocLowerLimit - hwSocDr_sum - BattSocInitDrop;
    city_prop = tcp_fine((tcp_fine(:,5) == 1),3)./sum(tcp_fine((tcp_fine(:,5) == 1),3));
    citySocDr_list = citySocNegDr_sum.*city_prop;
    tcp_fine((tcp_fine(:,5) == 1),6) = citySocDr_list;
end


for i = 1:cyc_len
    soc_liner_drop_traj(i) = BattSocInit - i*linerSocDr;
end

% theta-based SOC reference trajectory
for i = cyc_build_start_point:length(tcp_fine(:,3))
    tbSoc_ref = [tbSoc_ref, linspace(tbSoc_ref(end), tbSoc_ref(end)-tcp_fine(i,6), tcp_fine(i,3))];
end

if SOC_operation_mode == 0
    tbSoc_ref = [tbSoc_ref';tbSoc_ref(end)];
    tbSoc_ref = [transpose(linspace(1,length(tbSoc_ref),length(tbSoc_ref))),tbSoc_ref];
elseif SOC_operation_mode == 1
    tbSoc_ref = soc_liner_drop_traj';
    tbSoc_ref = [tbSoc_ref';tbSoc_ref(end)];
    tbSoc_ref = [transpose(linspace(1,length(tbSoc_ref),length(tbSoc_ref))),tbSoc_ref];
elseif SOC_operation_mode == 2
    tbSoc_ref = [transpose(linspace(1,DrvCycLen,DrvCycLen)),BattSocLowerLimit.*ones(DrvCycLen,1)];
end

if SOC_Traj_plot_enable

figure
hold on
yyaxis left
plot(vave_formal)

yyaxis right
plot(soc_liner_drop_traj, '--b', LineWidth=1)
plot(tbSoc_ref(:,2), '-r', LineWidth=2)
hold off

set(gcf,'Position',[347,162,800,220]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);

end