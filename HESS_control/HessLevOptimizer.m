%% Powered by XinhaoXu_Tesla 2023
% EMS4H // HessLevOptimizer

function [sys,x0,str,ts,simStateCompliance] = Self_learning_Markov(t,x,u,flag)

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
sizes.NumOutputs     = 3;
sizes.NumInputs      = 13;
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

vave_formal = u(1);
P_h = u(2);
ipt_const = u(3:11);
ssoc = u(12);
bsoc = u(13);


sc_discharge_limit = ipt_const(1);
sc_charge_limit = ipt_const(2);
sc_E = ipt_const(3);
Sc_pwr_upper_lmt = ipt_const(4);

BattSocLowerLimit = ipt_const(5);
BattSocUpperLimit = ipt_const(6);
Q_batt = ipt_const(7);
BattUoc = ipt_const(8);
Bat_power_max_kW = ipt_const(9);

% action_list = transpose(linspace(0.15,0.85,5));
action_list = transpose(linspace(0.3,0.7,5));

    % SOC_sc_ref Decision
    if vave_formal >= 26
        ssoc_ref = action_list(1);
    elseif vave_formal >= 20 && vave_formal < 26
        ssoc_ref = action_list(2);
    elseif vave_formal >= 12 && vave_formal < 20
        ssoc_ref = action_list(3);
    elseif vave_formal >= 4 && vave_formal < 12
        ssoc_ref = action_list(4);
    elseif vave_formal >= 0 && vave_formal < 4
        ssoc_ref = action_list(5);
    end


    if abs(P_h) > 0
        
        if P_h > 0.001 
            ssoc_lmt = 1-abs(ssoc-sc_discharge_limit)*sc_E/max([0.001, P_h * 1000]);
            bsoc_lmt = abs(bsoc-BattSocLowerLimit)*Q_batt*BattUoc/max([0.001, P_h * 1000]);
        else
            ssoc_lmt = 1-(-1)*abs(ssoc-sc_charge_limit)*sc_E/min([-0.001, P_h * 1000]);
            bsoc_lmt = (-1)*abs(bsoc-BattSocUpperLimit)*Q_batt*BattUoc/min([-0.001, P_h * 1000]);
        end

        batt_pwr_lmt = Bat_power_max_kW/max([0.001, abs(P_h)]);
        sc_pwr_lmt = 1 - Sc_pwr_upper_lmt/max([0.001, abs(P_h)]);
        
        lb_state = max([ssoc_lmt, sc_pwr_lmt, 0]);
        ub_state = min([bsoc_lmt, batt_pwr_lmt, 1]);

        % fmincon solving block /\/\/\/\/
        sqp_state = [bsoc; ssoc; ssoc_ref; P_h];

        alpha_set = transpose(linspace(lb_state,ub_state,200));
        cost_list = rwd_est(alpha_set, sqp_state);
        [opt_cost, idx] = min(cost_list(:,3));
        alpha_hess = alpha_set(idx);

    else

        alpha_hess = 1;

    end
    Reward = 0;




sys = [alpha_hess;Reward;ssoc_ref];


function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;


function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate



