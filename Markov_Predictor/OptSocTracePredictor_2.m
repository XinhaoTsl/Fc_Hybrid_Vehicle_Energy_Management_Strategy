%% Powered by XinhaoXu_tesla 2022
function [sys,x0,str,ts,simStateCompliance] = OptSocTracePredictor_2(t,x,u,flag)

switch flag,

  case 0,
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;

  case 1,
    sys=mdlDerivatives(t,x,u);

  case 2,
    sys=mdlUpdate(t,x,u);

  case 3,
    sys=mdlOutputs(t,x,u);

  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  case 9,
    sys=mdlTerminate(t,x,u);

  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 13;
sizes.NumInputs      = 22;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

x0  = [];
str = [];
ts  = [1 0];

simStateCompliance = 'UnknownSimState';

function sys=mdlDerivatives(t,x,u)
sys = [];


function sys=mdlUpdate(t,x,u)
sys = [];

%% Formal Block
function sys=mdlOutputs(t,x,u)

SLMP_Vset_vps = [u(1),u(2),u(3),u(4),u(5),u(6),u(7),u(8),u(9),u(10)];
dcsf = [u(11),u(12),u(13)];    % [v_std, v_ave, a_ave];

DrvState = u(14);
CurrDrvRange = u(15);
CurrBattSoc = u(16);

DrvCycLen = u(17);
BattSocLl = u(18);
AlphaRampFactor = u(19);
PredLen = u(20);
BattOnly = u(21);
BattSocRightNow = u(22);

sf = 0;
Ramp = 0;
RampFactor = 0;
SocTraceGuide = 0;

%     switch DrvState
% 
%         case 0  % Std_Conditioning
% 
%         case 9  % LowSpd_DeAcc
% 
%         case 10 % LowSpd_Conditioning
% 
%         case 11 % LowSpd_Acc
% 
%         case 19 % MidSpd_DeAcc
% 
%         case 20 % MidSpd_Conditioning
% 
%         case 21 % MidSpd_Acc
% 
%         case 29 % HighSpd_DeAcc
% 
%         case 30 % HighSpd_Conditioning
% 
%         case 31 % HighSpd_Acc
% 
%     end

SocTraceGuide = zeros(10,1);

UpcommingVset = SLMP_Vset_vps(1:PredLen+1);

DrvCycRemain_m = DrvCycLen - CurrDrvRange;

if BattOnly
    BattSocRemain = CurrBattSoc - BattSocRightNow;
else
    BattSocRemain = CurrBattSoc - BattSocLl;
end

SocDropPreMeter = BattSocRemain/DrvCycRemain_m;

SocDrop = 1.8*tril(SocDropPreMeter*ones(PredLen+1))*transpose(UpcommingVset);
SocTraceGuide(1:PredLen+1,1) = CurrBattSoc*ones(PredLen+1,1) - SocDrop;


sys = [SocTraceGuide; sf; Ramp; RampFactor];

% ostp_sf ostp_Ramp ostp_RampFactor


function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;


function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
