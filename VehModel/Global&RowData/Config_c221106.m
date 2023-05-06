clc
clear

load Driving_cycle_ori_data.mat;
load Driving_cycle_combined_ori_data.mat;
load Driving_cycle_recognition_data.mat;
load FCEV_original_data.mat
run ScParameter.m;

%% Replace The Cycle For Distribution Analyze
DrvCycKph = CYC_WVUSUB_kmph;

%% Test Critical Value
usd2rmb = 6;

%% Operation Path
DrvCycVps = [DrvCycKph(:,1),DrvCycKph(:,2)/3.6];
DrvCycLen = length(DrvCycKph(:,1));
AccSetIni = [DrvCycKph(:,1),zeros(DrvCycLen,1)];
AccSetIni_R = [DrvCycKph(:,1),zeros(DrvCycLen,1)];
PdtStrBit = 100;
PdtLen = 10;

for i=2:DrvCycLen
    AccSetIni(i,2) = DrvCycVps(i,2) - DrvCycVps(i-1,2);
    AccSetIni_R(i,2) = round(DrvCycVps(i,2) - DrvCycVps(i-1,2),1);
end

DrvCycVps_R = [DrvCycKph(:,1),zeros(DrvCycLen,1)];
DrvCycVps_0 = [DrvCycKph(:,1),zeros(DrvCycLen,1)];

for i =2:DrvCycLen
    DrvCycVps_R(i,2) = DrvCycVps_R(i-1,2) + AccSetIni_R(i,2);
    DrvCycVps_0(i,2) = DrvCycVps(i-1,2) + AccSetIni(i,2);
end

valref = fitdist(AccSetIni(:,2),'Normal')
histfit(AccSetIni(:,2))
nnn = find(abs(AccSetIni(:,2)-0) <= 1e-4);

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