%% xinhaoxu@tesla.com
%  Optimal Batt Soc traj generator
%  Optimal theta distribution plot

Pure_Plot_Mode = 0;

if ~Pure_Plot_Mode

clc
clear

run Config_c230321.m
load GeneratedCyc_HwPropFrom05to95.mat
load theta_OperationResults_0124_02.mat

is_Generated_Cyc = 0;

% CYC_combined_kmph 
% CYC_NREL2VAIL_kmph 

% CYC_TH_kmph 
% CYC_TU_kmph
% CYC_VAIL2NREL_kmph


if ~is_Generated_Cyc
    % General Cyc Format
    run DP_forOptSocTrajGenerate_Calling.m

else
    % Generated Cyc Format
    load GeneratedCyc_HwPropFrom05to95.mat
    load theta_OperationResults_0124_02.mat
    
    nProp = 4;
    DrvCycKph = [transpose(1:length(GeneratedCyc_Msg(:,nProp))),GeneratedCyc_Msg(:,nProp)];
    Pbatt_opt = Pbatt_opt_Rec(:,:,nProp);
end

end

SubtcpLen = 20;
BattSocInit = 0.8;
ts = 1;



DrvCycVps = [DrvCycKph(:,1),DrvCycKph(:,2)/3.6];
DrvCycLen = length(DrvCycKph(:,1));
DrvCycRange = sum(DrvCycVps(:,2));

sim("VehDymcModel_Outputer")
P_dem = Preq_w_LookupTable;
len = length(P_dem);


% Battery Msg
BattSocUpperLimit = 0.8;
BattSocLowerLimit = 0.3;
U_oc = 320;  % [V]
Bat_ori_cap_max_Ah = 20.7; Q_batt = Bat_ori_cap_max_Ah*3600;   % [As] Battery capacity
Pb_max = Bat_power_max_kW*1000; % [W]

% SOC_grid considered the condition under pure CD / CDCS 
if BattSocInit - BattSocLowerLimit >= 0.05
    SOC_grid = linspace(BattSocLowerLimit,BattSocUpperLimit,80)';
else
    SOC_grid = linspace(BattSocLowerLimit-0.05,BattSocUpperLimit,80)';
end


FC_ori_power_kW = [0,2,5,7.500000000000000,10,20,30,40,50];
FC_ori_fuel_rate_gps = [0,0.050505050505051,0.084688346883469,0.117260787992495,0.149075730471079,0.279642058165548,0.423011844331641,0.593119810201661,0.820209973753281];

SOC_traj(1) = BattSocInit;

for i = 1:len-1
    P_batt_traj(i) = interp1(SOC_grid,Pbatt_opt(:,i),SOC_traj(i));
    P_fc_traj(i) = P_dem(i) - P_batt_traj(i);
    Cost(i) = 30/1000 * interp1(FC_ori_power_kW, FC_ori_fuel_rate_gps, P_fc_traj(i)./1000);
    SOC_traj(i+1) = SOC_traj(i) - ((ts*P_batt_traj(i))/(Q_batt*U_oc));       
end


% SOC Drop Flag
figure
title_name = 'Batt Soc Ramp Under DrvCyc';
xlabel_msg = 'Driving Step';
xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);

yyaxis left
% plot(SOC_traj,'-g', LineWidth=2);
plot(SOC_traj(4000:4200),'-g', LineWidth=2);
ylabel('BattSoc','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);

yyaxis right
% plot(DrvCycKph(:,2),'-b', LineWidth=1);
plot(DrvCycKph(4000:4200,2),'-b', LineWidth=1);
ylabel('VehicleSpeed','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);

legend({'BattSoc','VehSpeed'}, 'Location', 'northeast')
title(title_name,'FontName','Times New Roman','FontSize',11);
% set(gcf,'Position',[347,162,800,220]);
set(gcf,'Position',[347,162,380,160]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);

[vstd_formal, vave_formal, a_ave_formal] = Fun_SLMP(DrvCycKph);

hold off;

%% Rolling Optimal Parameter Solver
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
        if max(vave_formal(step)) <= 10
            dct(step) = 1; 
        elseif max(vave_formal(step)) <= 25 & max(vave_formal(step)) > 10
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

            elseif svas <= 10
                if sum(ssVacc>=5)
                    if max(ssVspd) > 1.2*10 & floor(min(ssVspd)) == 0
                        dct(step) = 2;
                    elseif sum(ssVspd>10) > updateLen/2
                        dct(step) = 2; 
                    elseif max(ssVspd) < 1.2*10
                        dct(step) = 1;
                    end
                    dct(step) = 1; 
                end
                dct(step) = 1;
    
            elseif svas > 10 && svas <= 25
                if sum(ssVspd>25) > updateLen/2
                    if ssVspd(1) >= 25 && ssVspd(end) >= 25
                        dct(step) = 3;
                    elseif ssVspd(1) >= 25 && svas > 0.8*25
                        dct(step) = 3;
                    elseif max(ssVspd) > 25*1.2
                        dct(step) = 3;
                    else
                        dct(step) = 2;
                    end
                    dct(step) = 2;
                elseif ssVspd(1) >= 25 && ssVspd(end) >= 25
                    dct(step) = 3;
                elseif ssVspd(1) >= 25 && svas > 0.8*25
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

figure
hold on

title('DrvCyc Type','FontName','Times New Roman','FontSize',11);
xlabel('Drive Step','FontName','Times New Roman','FontSize',11);

yyaxis left
plot(vave_formal);
ylabel('Average VehSpd m/s','FontName','Times New Roman','FontSize',11,LineWidth=1.5);

yyaxis right
% plot(dct,'r', LineWidth=2);
plot((3/0.8)*SOC_traj,'r',LineWidth=1);
plot(Fixedct,'-g', LineWidth=2);
ylabel('DrvCyc Type','FontName','Times New Roman','FontSize',11,LineWidth=1.5);

legend({'VehSpd','SOC_d_r_o_p', 'DrvCyc Type'}, 'Location', 'northeast')

set(gcf,'Position',[347,162,800,220]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);

hold off



%% Ramping Calculation

tcpCount = 1;
tcp = [1, 1, 0, SOC_traj(1), 0, 0, 0, 0, 0, 0];
% tcp = [*CycStratStep, *CycStopStep, CycLen, CycType, StepSoc, SubCycSocDrop, 
%               1             2          3       4        5           6
%        CycVave, SubCycSocDropRate, CycSocDropRate, SocDropFactor]
%           7             8                9               10

for i = 1:length(Fixedct)

    if i < 2
        ;
    elseif i >= 2
        if abs(Fixedct(i)-Fixedct(i-1))
            tcpCount = tcpCount + 1;    % Cycle Type Conversion Point
            tcp(tcpCount,1) = tcp(tcpCount-1,2);
            tcp(tcpCount,2) = i;
            tcp(tcpCount,3) = tcp(tcpCount,2) - tcp(tcpCount,1);
            tcp(tcpCount,4) = Fixedct(i-1);
            tcp(tcpCount,5) = SOC_traj(i);
            tcp(tcpCount,6) = tcp(tcpCount-1,5)-tcp(tcpCount,5);
            tcp(tcpCount,7) = mean(vave_formal(tcp(tcpCount,1):i));
            tcp(tcpCount,8) = tcp(tcpCount,6)/tcp(tcpCount,3);
            tcp(tcpCount,9) = (BattSocUpperLimit - BattSocLowerLimit)/length(Fixedct);
            tcp(tcpCount,10) = tcp(tcpCount,8)/tcp(tcpCount,9);
        end
    end
end


subtcp = [0,0,0,0,0,0,0];
% subtcp = [UnitCycType, UnitCycVave, UnitCycSocDrop, UnitCycSocDropRate
%                1             2             3                4
%           CycSocDropRate, UnitSocDropFactor]
%                5                 6


subtcpCount = 0;
HwLen = 0;

for tcpGoThrough = 1:tcpCount

    if tcp(tcpGoThrough,3) > 49*2 && tcp(tcpGoThrough,4) == 3   
    
        for i = [tcp(tcpGoThrough,1):SubtcpLen:tcp(tcpGoThrough,2)]
            subtcpCount = subtcpCount + 1;
    
            subtcp(subtcpCount,1) = 3;
            subtcp(subtcpCount,2) = mean(vave_formal(i:i+SubtcpLen-1));
            subtcp(subtcpCount,3) = SOC_traj(i) - SOC_traj(i+SubtcpLen-1);
            subtcp(subtcpCount,4) = subtcp(subtcpCount,3)/SubtcpLen;
            subtcp(subtcpCount,5) = tcp(tcpGoThrough,9);
            subtcp(subtcpCount,6) = subtcp(subtcpCount,4)/subtcp(subtcpCount,5);
       
        end
    end

    if tcp(tcpGoThrough,4) == 3

        HwLen = HwLen + tcp(tcpGoThrough,3);
        PrepHwLen = HwLen/length(Fixedct);
    end

end

fprintf("The proportion of the Highway Cyc is: %.2f\n", PrepHwLen*100);


%% Liner Regression
% Copyed Algorithm from CSDN // URL: 
% https://blog.csdn.net/bryant_meng/article/details/78640407?ops_request_misc=&request_id=&biz_id=102&utm_term=matlab%E4%BA%8C%E7%BB%B4%E7%9B%B4%E7%BA%BF%E5%9B%9E%E5%BD%92&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-4-78640407.142^v71^wechat,201^v4^add_ask&spm=1018.2226.3001.4187

X = subtcp(:,2);   % Vave shatter
y = subtcp(:,6);   % Ramping Factor

fprintf('Plotting Data ...\n')

m = length(y); 

figure; % open a new figure window
plot(X , y , 'rx' , 'MarkerSize' , 10);

X = [ones(m, 1), subtcp(:,2)]; 

% Parameter Initialization theta = (b, a)
% Regressioned Line -> y = ax + b
theta = zeros(2, 1); 

% Some gradient descent settings
iterations = 1500;
alpha = 0.001;

% computeCost(X, y, theta)
theta = gradientDescent(X, y, theta, alpha, iterations);

fprintf('Theta found by gradient descent: ');
fprintf('%f %f \n', theta(1), theta(2));
% (-3.630291,1.166362)

hold on; 
% keep previous plot visible

plot(X(:,2), X*theta, '-')

legend('Training data', 'Linear regression')

hold off 
% don't overlay any more plots on this figure
