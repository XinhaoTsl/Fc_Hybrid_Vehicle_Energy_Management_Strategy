%% Powered by XinhaoXu_tesla 2022
% Fucel Cell Power Slow Drop (FPSD)

function [sys,x0,str,ts,simStateCompliance] = SecLevOptimizer(t,x,u,flag)

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
sizes.NumOutputs     = 2;
sizes.NumInputs      = 7;
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

FunctionTigger = u(1);
FunctionCall = u(2);
DropCall = u(3);
FcPwrTigger = u(4);
BattSoc = u(5);
BattSocUpperLimit = u(6);
FcPwrRef = u(7);

FcPwrDropCall = 6;

persistent ftp      % Fuel Cell Tigger Power
persistent ftSoc    % BattSoc Tigger Value
persistent fpsdtp   % TimeStep of FPSD
persistent opdr     % Optimal Fuelcell PowerDrop
persistent opfp     % Optimal Fuelcell OptPwr
persistent opds     % Optimal Fuelcell OptPwr

if t <= 1
    opfp = FcPwrRef;
    opdr = 0;
    opds = 1;
    fpsdtp = 1;
end

% OPDS LookupTable // Cal in /Algorithm/OptControl_Demo/FuelcellSlowDrop.m
DropStepRef_x = [50;49.5000000000000;49;48.5000000000000;48;47.5000000000000;47;46.5000000000000;46;45.5000000000000;45;44.5000000000000;44;43.5000000000000;43;42.5000000000000;42;41.5000000000000;41;40.5000000000000;40;39.5000000000000;39;38.5000000000000;38;37.5000000000000;37;36.5000000000000;36;35.5000000000000;35;34.5000000000000;34;33.5000000000000;33;32.5000000000000;32;31.5000000000000;31;30.5000000000000;30;29.5000000000000;29;28.5000000000000;28;27.5000000000000;27;26.5000000000000;26;25.5000000000000;25;24.5000000000000;24;23.5000000000000;23;22.5000000000000;22;21.5000000000000;21;20.5000000000000;20;19.5000000000000;19;18.5000000000000;18;17.5000000000000;17;16.5000000000000;16;15.5000000000000;15;14.5000000000000;14;13.5000000000000;13;12.5000000000000;12;11.5000000000000;11;10.5000000000000;10;9.50000000000000;9;8.50000000000000;8;7.50000000000000;7;6.50000000000000;6;5.50000000000000;5;4.50000000000000;4];
DropStepRef_y = [9;9;9;9;9;6;6;7;7;8;8;8;8;8;8;8;8;8;8;8;10;7;7;7;7;7;7;7;7;7;8;8;8;8;8;8;8;6;6;6;7;7;7;7;7;7;7;5;5;5;6;6;6;6;6;6;6;4;4;4;5;5;5;5;5;5;5;4;4;3;4;4;4;4;3;3;3;3;3;2;2;2;2;2;2;2;2;2;2;1;1;1;1];

if FunctionCall == 1

    switch FunctionTigger  

        case 1  % FPSD Initializion

            ftp = FcPwrTigger;
            ftSoc = BattSoc;
            fpsdtp = 1; % Initializion of TimeStep
            opds = ceil(interp1(DropStepRef_x,DropStepRef_y,ftp));    % Optimal OptPwrDropSteps
            opdr = ftp/opds;    % Optiaml OptPwrDropRate

%           options = optimoptions('fmincon','Display','off','Algorithm','sqp');
%           x = fmincon('fpsdoptimizer', x0, [], [], [], [], lb, ub, [], options);

            opfp = ftp - fpsdtp*opdr;   % OptimalFuelcellpwrOpt

            fpsdtp = fpsdtp + 1;    % TimeStep Accumulation

        case 0  % FPSD Implementation
            
            if fpsdtp > 1 && fpsdtp < opds
                opfp = ftp - fpsdtp*opdr;
                fpsdtp = fpsdtp + 1;    % TimeStep Accumulation

            elseif fpsdtp == opds
                opfp = FcPwrRef;
                opdr = 0;
                opds = 1;
                fpsdtp = 1;
            end
    end

elseif FunctionCall == 0 && fpsdtp > 1 % FPSD Special Condition
    
    if abs(opfp-FcPwrRef) >= FcPwrDropCall
        
        opfp = ftp - fpsdtp*opdr;
        fpsdtp = fpsdtp + 1;    % TimeStep Accumulation

    else
        opfp = FcPwrRef;
        opdr = 0;
        opds = 1;
        fpsdtp = 1;
    end

else    % Generally Condition (None FPSD)
    opfp = FcPwrRef;
    opdr = 0;
    opds = 1;
    fpsdtp = 1;

end





%%

sys = [opfp;opdr]; 


function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;


function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
