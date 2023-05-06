clc
clear

load Driving_cycle_ori_data.mat;
load Driving_cycle_combined_ori_data.mat;
load Driving_cycle_recognition_data.mat;
load FCEV_original_data.mat
run ScParameter.m;

%% Replace The Cycle For Distribution Analyze
DrvCycKph = CYC_WVUINTER_kmph;

%% Operation Path
DrvCycVps = [DrvCycKph(:,1),DrvCycKph(:,2)/3.6];
DrvCycLen = length(DrvCycKph(:,1));
DrvCycRange = sum(DrvCycVps(:,2));

% Self Learning Markov Config Value
PredLen = 5;
SLMP_LearningRate = 0.05;

% Battery SOC Traj config
BattSocInit = 0.9;
BattSocUpperLimit = 0.9;
BattSocLowerLimit = 0.25;
AlphaRampFactor = 8;
BattValuePlaceholder = 0;

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

% for i = 1:PdtLen
%     AccSet = AccSetIni(PdtStrBit+i:PdtStrBit+i+PdtLen);


% plot(AccSetIni(:,1),AccSetIni(:,2),'-o');
% hold on
% plot(AccSetIni_R(:,1),AccSetIni_R(:,2),'--*');
% hold off

% plot(DrvCycVps(:,1),DrvCycVps(:,2),'g',LineWidth=3);
% hold on
% plot(DrvCycVps_R(:,1),DrvCycVps_0(:,2),'r-',LineWidth=1);
% hold on
% plot(DrvCycVps_0(:,1),DrvCycVps_R(:,2),'b--',LineWidth=2);
% hold off


% AccSetPool = [];

disp('Model Configuration Initialization completed')