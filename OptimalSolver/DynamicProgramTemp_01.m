clc
clear

load GeneratedCyc_HwPropFrom05to95.mat
load Driving_cycle_ori_data.mat;
load Driving_cycle_combined_ori_data.mat;
load Driving_cycle_recognition_data.mat;
load FCEV_original_data.mat
run ScParameter.m;

run PureHwCycGenerator.m

%% Replace The Cycle For Distribution Analyze
DrvCycKph = CYC_combined1_kmph;   % General Cyc Format

nProp = 5;
% DrvCycKph = [transpose(1:length(GeneratedCyc_Msg(:,nProp))),GeneratedCyc_Msg(:,nProp)];


DrvCycVps = [DrvCycKph(:,1),DrvCycKph(:,2)/3.6];
DrvCycLen = length(DrvCycKph(:,1));
DrvCycRange = sum(DrvCycVps(:,2));

title('DrvCycKph')
plot(DrvCycKph(:,2));

sim("VehDymcModel_Outputer")
P_dem = Preq_w_LookupTable;
len = length(P_dem);


% Fuel cell Config Value
Pf_max = FC_power_max_kW*1000; % [W]
FcPwrDropCall = 6;  % [kW]
DeltaFcPwrRcm_up = 2.5;  % Hard Limitation of the FcPwr Variation
DeltaFcPwrRcm_down = 0.5;
HydpriceRmb = 30;
tDegTable = [zeros(1,3),linspace(0,0.13,47)];
FC_ori_power_kW = [0,2,5,7.500000000000000,10,20,30,40,50];
FC_ori_fuel_rate_gps = [0,0.050505050505051,0.084688346883469,0.117260787992495,0.149075730471079,0.279642058165548,0.423011844331641,0.593119810201661,0.820209973753281];


% Battery Config Value
BattSocInit = 0.8000;
BattSocUpperLimit = 0.8;
BattSocLowerLimit = 0.3;
BattUoc = 320;  % [V]
Bat_ori_cap_max_Ah = 20.7; Q_batt = Bat_ori_cap_max_Ah*3600;   % [As] Battery capacity
Pb_max = Bat_power_max_kW*1000; % [W]

% SOC_grid considered the condition under pure CD / CDCS 
if BattSocInit - BattSocLowerLimit >= 0.05
    SOC_grid = linspace(BattSocLowerLimit,BattSocUpperLimit,80)';
else
    SOC_grid = linspace(BattSocLowerLimit-0.05,BattSocUpperLimit,80)';
end

% Cost to go table
C2G = zeros(length(SOC_grid),len);
C2G(:,end) = 0;

h=waitbar(0,'Processing');

for step = len-1:-1:1
    waitbar((len-step)/len,h)
    for SocState = 1:length(SOC_grid)

        % Debug
        fprintf("P_dem: %5.4f, step: %4.0f;\n", P_dem(step), step);
        fprintf("SOC_grid: %1.4f, SocState: %2.0f;\n" , SOC_grid(SocState), SocState);

        if SocState == 75
            disp("STOP HERE")
        end

        % The MaxChgPwr -> Normal Negative Value
        Pbatt_lb = max([((BattSocUpperLimit-SOC_grid(SocState))*(-1)*Q_batt*BattUoc),-Pb_max, P_dem(step)-Pf_max]);
        % The MaxDisChgPwr -> Positive Value
        Pbatt_ub = min([((BattSocLowerLimit-SOC_grid(SocState))*(-1)*Q_batt*BattUoc),Pb_max, P_dem(step)]);

        Pbatt_grid = linspace(Pbatt_lb,Pbatt_ub,250);
        Pf_grid = abs(P_dem(step) - Pbatt_grid);

        % Element of C2G table -> c2g
        FcHydconRmb = 30/1000 * interp1(FC_ori_power_kW, FC_ori_fuel_rate_gps, Pf_grid./1000);
        FcDegConRmb = 0;
        c2g = FcHydconRmb + FcDegConRmb;
        
        % Calculate the SOC_next for mapping the cost of the rest steps
        SOC_nxt = roundn(SOC_grid(SocState) - (Pbatt_grid ./ (Q_batt*BattUoc)), -4);
        c2g_nxt = interp1(SOC_grid,C2G(:,step+1),SOC_nxt);

        % Find the minimum value of each Batt_grid condition
        [C2G(SocState,step), k] = min([c2g + c2g_nxt]);
        
        % Bulid the Pbatt table which has same mapping relationship to the c2g
        % Use the c2g's [a,b] indexs the Pbatt for time saving
        Pbatt_opt(SocState,step) = Pbatt_grid(k); 

    end
end

disp('ProjCompleted')
delete(h);

[Pb_07, Pe_07, FC_07, SOC_07]= RUN_HEV(0.8,len,SOC_grid,Pbatt_opt,P_dem);
[Pb_05, Pe_05, FC_05, SOC_05]= RUN_HEV(0.5,len,SOC_grid,Pbatt_opt,P_dem);
[Pb_03, Pe_03, FC_03, SOC_03]= RUN_HEV(0.3,len,SOC_grid,Pbatt_opt,P_dem);

figure;
plot(SOC_07)
hold on;
plot(SOC_05)
plot(SOC_03)
title('SOC')
legend('SOC 0.7','SOC 0.5','SOC 0.3')
hold off

PreSettingBattSocTraj = [transpose(1:length(SOC_07)),SOC_07'];
HydCom(1) = 0;


