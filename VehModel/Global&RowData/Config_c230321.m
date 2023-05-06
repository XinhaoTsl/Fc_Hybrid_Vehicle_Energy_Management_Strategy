%% Powered by Xinhaoxu_Tesla
%  Core dependency of all the .m script and the simulink model.
%  Parameters initializer.

%  Pls expect the long term logging period for the first time running this script.

clc
clear

global nbl_std
global Bat_ori_SOC2
global Bat_ori_Uoc_dis_V
global Bat_ori_Uoc_chg_V

load Driving_cycle_ori_data.mat;
load Driving_cycle_combined_ori_data.mat;
load Driving_cycle_recognition_data.mat;
load FCEV_original_data.mat

% run PureHwCycGenerator.m

%% Replace The Cycle For Distribution Analyze
DrvCycKph = CYC_combined_kmph;

% SOC operation mode (SOM)
% 0: theta-based; 1: liner-based; 2: CDCS-based;
SOC_operation_mode = 0;
SOC_Traj_plot_enable = 1;
no_FcPwrSlowDrop = 1;

if length(DrvCycKph(1,:)) == 1
    DrvCycKph = [transpose(linspace(0,length(DrvCycKph(:,1))-1,length(DrvCycKph(:,1)))), DrvCycKph];
elseif length(DrvCycKph(1,:)) > 2
    DrvCycKph = transpose(DrvCycKph);
    DrvCycKph = [transpose(linspace(0,length(DrvCycKph(:,1))-1,length(DrvCycKph(:,1)))), DrvCycKph];
end


% nProp = 5;
% DrvCycKph = [transpose(1:length(GeneratedCyc_Msg(:,nProp))),GeneratedCyc_Msg(:,nProp)];


% Cost Function Weighting Factor (CFWF)
CFWF = 0.5; 

%% Operation Path
DrvCycVps = [DrvCycKph(:,1),DrvCycKph(:,2)/3.6];
DrvCycLen = length(DrvCycKph(:,1));
DrvCycRange = sum(DrvCycVps(:,2));

% DrvPattern Recognition Calibration Parameter
city2sub = 11;
sub2hw = 25;
hwSocDr_inc_factor = 1;

% Self Learning Markov Config Value
PredLen = 5;
SLMP_LearningRate = 0.05;

% Fuel cell Config Value
FcPwrDropCall = 6;
DeltaFcPwrRcm_up = 4;  % Hard Limitation of the FcPwr Variation per step
DeltaFcPwrRcm_down = 0.5;
HydpriceRmb = 30;
tDegTable = [zeros(1,3),linspace(0,0.13,47)];

% Battery Config Value
BattSocInit = 0.8;
BattSocUpperLimit = 0.8;
BattSocLowerLimit = 0.3;
BattSocInitDrop_rate = 0.05/1400;
AlphaRampFactor = 8;
Placeholder = 0;
BattInitTemp = 25;
BattCell_voltage = 3.3;
BattCell_current = 2.3;
BattPack_voltage = BattCell_voltage * 97;
BattPack_current = BattCell_current * 9;
Q_batt = 18000; 

% Sc Config Value
global sc_E
global sc_charge_limit
global sc_discharge_limit
global sc_soc_acceptableRange

sc_soc_init = 0.5;
sc_soc_acceptableRange = 0.2;

SC_rc = 1000; % Capacity of Sc (F)
SC_rv = 3.2; % Rate output voltage (V)
SC_ns = 100; % Number of the serially connected Sc
SC_np = 1; % Number of the parallely connected Sc
SC_rate_current = 200; % unit -> A (AVX SCMT2150F-273L16)
Sc_pwr_upper_lmt = SC_rv*SC_ns*SC_rate_current/1000;

sc_charge_limit = 0.9;
sc_discharge_limit = 0.1;

C_eff  =  SC_rc * SC_np/SC_ns; % Unit: F (Farads)
V_eff =  SC_rv * SC_ns; % Unit: V (Volt)
sc_E = 0.5 * C_eff * V_eff^2;


% nbl (Normal Battery Lifetime)
nbl_btm = (0.5*2694.5+6022.2)*exp((-31700+152.5)/(8.314*298.15));
nbl_std = (20/nbl_btm)^(1/0.57);


% Working condition state machine transfer threshold value
Vth_c2l = 2;
Vth_l2m = 10;
Vth_m2h = 22;

AccThrshd = 1;
DeAccThrshd = -1;
VstdThrshd = 2;

% Price exchange
usd2rmb = 6;

%% Acc Distribute Analysis
% valref = fitdist(AccSetIni(:,2),'Normal')
% histfit(AccSetIni(:,2))
% nnn = find(abs(AccSetIni(:,2)-0) <= 1e-4);


%% others
sim("VehDymcModel_Outputer")

BattUoc = 320;
Bat_ori_cap_max_Ah = 20.7;
BattSocRightNow = BattSocInit;

SFun_ipt = [sc_discharge_limit;sc_charge_limit;sc_E;Sc_pwr_upper_lmt;BattSocLowerLimit;...
    BattSocUpperLimit;Q_batt;BattUoc;50;];

% Soc Drop pre step
DeltaSocPrePwrKw = 1000 / (Bat_ori_cap_max_Ah * 3600 * BattUoc);

for i=1:DrvCycLen
    SocDrop = (Preq_w_LookupTable(i)/1000) * DeltaSocPrePwrKw;
    BattSocRightNow = BattSocRightNow - SocDrop;
end

BattOnly = double(BattSocRightNow > BattSocLowerLimit);


%% Pattern Recognition & Opt SOC Traj Generation
run OptSocRampingTrajGenerator.m
% run SOC_traj_comp.m


%% DrvCyc Msg outputter
fprintf("BatterySocInit: %1.1f\n",BattSocInit)
fprintf("BatteryOnly: %d\n",BattOnly)
fprintf("Highway proportion: %f\n",hw_prop*100)
fprintf("Is highway SOC drop exceed: %d\n",is_hwSocExceed)
fprintf("Battery SOC operation mode: %d\n",SOC_operation_mode)
fprintf("Value hwSocDr_inc_factor: %d\n",hwSocDr_inc_factor)
fprintf("SOC ref Traj length Correctness: %d\n",length(tbSoc_ref(:,1)) == ...
    length(DrvCycKph(:,1)))
disp('Model Configuration Initialization completed')