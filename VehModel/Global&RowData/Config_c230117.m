clc
clear

load CYC_combined_230312_03.mat
load GeneratedCyc_HwPropFrom05to95.mat
load Driving_cycle_ori_data.mat;
load Driving_cycle_combined_ori_data.mat;
load Driving_cycle_recognition_data.mat;
load FCEV_original_data.mat
run ScParameter.m;

% run PureHwCycGenerator.m

%% Replace The Cycle For Distribution Analyze
DrvCycKph = CYC_TU_kmph;

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

% Self Learning Markov Config Value
PredLen = 5;
SLMP_LearningRate = 0.05;

% Fuel cell Config Value
FcPwrDropCall = 6;
DeltaFcPwrRcm_up = 4;  % Hard Limitation of the FcPwr Variation
DeltaFcPwrRcm_down = 0.5;
HydpriceRmb = 30;
tDegTable = [zeros(1,3),linspace(0,0.13,47)];

% Battery Config Value
BattSocInit = 0.8;
BattSocUpperLimit = 0.8;
BattSocLowerLimit = 0.3;
BattSocInitDrop = 0.04;
AlphaRampFactor = 8;
Placeholder = 0;
BattInitTemp = 25;

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

% Soc Drop pre step
DeltaSocPrePwrKw = 1000 / (Bat_ori_cap_max_Ah * 3600 * BattUoc);

for i=1:DrvCycLen
    SocDrop = (Preq_w_LookupTable(i)/1000) * DeltaSocPrePwrKw;
    BattSocRightNow = BattSocRightNow - SocDrop;
end

BattOnly = BattSocRightNow > BattSocLowerLimit;


%% Pattern Recognition
run OptSocRampingTrajGenerator.m


%% DrvCyc Msg outputter
disp('Model Configuration Initialization completed')
fprintf("BatterySocInit: %1.1f\n",BattSocInit)
fprintf("BatteryOnly: %d\n",BattOnly)
fprintf("Highway proportion: %f\n",hw_prop*100)