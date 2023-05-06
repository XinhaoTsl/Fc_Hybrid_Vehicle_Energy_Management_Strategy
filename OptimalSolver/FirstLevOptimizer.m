%% Powered by XinhaoXu_tesla 2022
% Main PowerSplit Optimizer (MPO)

function [sys,x0,str,ts,simStateCompliance] = FirstLevOptimizer(t,x,u,flag)

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
sizes.NumOutputs     = 30;
sizes.NumInputs      = 35;
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
sys = []

%% Formal Block
function sys=mdlOutputs(t,x,u)


%% Ipt Value
global BattSocRef BattSocLog FcPwrLog
global cfwf PredLen usd2rmb
global Cost

PwrReq = [u(1),u(2),u(3),u(4),u(5),u(6),u(7),u(8),u(9),u(10)];
PredLen = u(11);

BattSocUpperLimit = u(12);
BattSocLowerLimit = u(13);
EmptyValue = u(14);
BattPwrMaxKw = u(15);
BattPwrMinKw = u(16);
BattOnly = u(17);
DeltaFcPwrRcm_down = u(18);
BattSocLog = u(19);

FcPwrMaxKw = u(20);
FcPwrMinKw = u(21);
FcPwrLog = u(22);
DeltaFcPwrRcm_up = u(23);  % Delta FuelCell Opt Power Restrain Control Module
usd2rmb = u(24);
cfwf = u(25);
BattSocRefset = [u(26),u(27),u(28),u(29),u(30),u(31),u(32),u(33),u(34),u(35)];

BattSocRef = transpose(BattSocRefset(1:PredLen+1));

%% Operation block

% Mid-task stop tigger
if t ==100  % enter the 
    disp "stophere"
end

if PwrReq(1) == 0   % IdleSpeed ===========================================
    
    FcPwrOptKw = zeros(10,1);
    BattPwrOptKw = zeros(10,1);

    BattSocOfst = zeros(10,1);
    Cost = 0;

%     x1 = 0; % Need to consider the Fc Idel working condition issue
%     x2 = 0; % 

elseif PwrReq(1) > 0    % NonDeAcc ========================================
    
    FcPwrOptKw = zeros(10,1);
    BattPwrOptKw = zeros(10,1);

    BattSocOfst = zeros(10,1);
    Cost = 0;

    % Hard Constraint
    lb = zeros(2 * (PredLen+1),1);
    ub = zeros(2 * (PredLen+1),1);
    
    % FcOptPwr with Dynamic constraint /////
    lb(1:(PredLen+1),1) = max(FcPwrMinKw,FcPwrLog - DeltaFcPwrRcm_down);
    ub(1:(PredLen+1),1) = min(FcPwrMaxKw,FcPwrLog + DeltaFcPwrRcm_up);

    % FcOptPwr without Dynamic constraint /////
%     lb(1:(PredLen+1),1) = FcPwrMinKw;
%     ub(1:(PredLen+1),1) = FcPwrMaxKw;
    
    % Battery Pwr Hard Restrain
    Q_batt = 18000;
    U_oc = 320; 
    SocBaseJudger = abs(BattSocLowerLimit - BattSocLog)*Q_batt*U_oc;
    
    ub((PredLen+1)+1:2*(PredLen+1),1) = min(BattPwrMaxKw,SocBaseJudger);
    lb((PredLen+1)+1:2*(PredLen+1),1) = BattPwrMinKw;   % Will be updated soon

    % Liner Equal Constraint
    DCDC_ori_eff = mean([0.950,0.960,0.970,0.976,0.980,0.978,0.973,0.962]);

    Aeq11 = DCDC_ori_eff * eye((PredLen+1));
    Aeq12 = eye((PredLen+1));

    Aeq = [Aeq11,Aeq12];
    beq = PwrReq(1:PredLen+1);

    % Init Value
    x0 = zeros(2*(PredLen+1),1);
   
    % fmincon zoon
    options = optimoptions('fmincon','Display','off','Algorithm','sqp');
    x=fmincon('MainCostFun', x0, [], [], Aeq, beq, lb, ub, [], options);


%     x1=x(1,1);
%     x2=x((PredLen+1)+1,1);

    FcPwrOptKw(1:(PredLen+1)) = x(1:(PredLen+1));

    BattUoc = 320;
    Bat_ori_cap_max_Ah = 20.7;
    
    BattPwrOptKw(1:(PredLen+1)) = x((PredLen+2):2*(PredLen+1));
       
    DeltaSocPrePwrKw = 1000 / (Bat_ori_cap_max_Ah * 3600 * BattUoc);
        
    SocDrop = tril(DeltaSocPrePwrKw*ones(10))*BattPwrOptKw;
    BattSocOpt = BattSocLog*ones(10,1) - SocDrop;
        
    BattSocOfst(1:(PredLen+1),1) = abs(BattSocOpt(1:(PredLen+1),1)-BattSocRef);


else % PwrReq(1) < 0 ======================================================

    FcPwrOptKw = zeros(10,1);
    BattPwrOptKw = max(PwrReq(1),(-1)*BattPwrMaxKw) * ones(10,1);

    BattSocOfst = zeros(10,1);
    Cost = 0;

%     x1 = 0; % No Pwr feedback to the Fc while the RegBraking
%     x2 = max(PwrReq(1),(-1)*BattPwrMaxKw);  % General Restrain for temp
end


%% Optimized Value Diagnostic



%%

sys = [FcPwrOptKw;BattPwrOptKw;BattSocOfst];  % x1 = [Pfc];  x2 = [Pb];


function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;


function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
