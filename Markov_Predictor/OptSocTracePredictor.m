%% Powered by XinhaoXu_tesla 2022
function [sys,x0,str,ts,simStateCompliance] = OptSocTracePredictor(t,x,u,flag)

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
sizes.NumOutputs     = 4;
sizes.NumInputs      = 9;
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

    dcsf = [u(1),u(2),u(3)];    % [v_std, v_ave, a_ave];

    DrvState = u(4);
    DrvCycLen = u(5);
    CurrBattSoc = u(6);

    CurrDrvRange = u(7);
    BattSocLl = u(8);
    AlphaRampFactor = u(9);

    sf = 0;
    Ramp = 0;
    RampFactor = 0;
    SocTraceGuide = 0;


    if dcsf(3) >= 0
        sf = (-1)*dcsf(1)/30;
    elseif dcsf(3) < 0
        sf = (-1)*(-1)*dcsf(1)/30;
    end


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
    if abs(DrvCycLen - CurrDrvRange) > 2
        Ramp = (CurrBattSoc - BattSocLl)/(DrvCycLen - CurrDrvRange);
    else
        Ramp = 0;
    end

    RampFactor = AlphaRampFactor/(1+sf); 

    SocTraceGuide = CurrBattSoc - RampFactor * Ramp;
    % SocTraceGuide = CurrBattSoc - Ramp;

sys = [SocTraceGuide,sf,Ramp,RampFactor];
% ostp_sf ostp_Ramp ostp_RampFactor


function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;


function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
