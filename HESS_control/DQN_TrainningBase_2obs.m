%% Powered by Xinhaoxu_Tesla
%  Two Obs inside the training Agent, simple version
%  Create the DQN Env and Trainning Agent with the MATLAB object.

run Config_c230321.m
load 230415_Pure_BattPwrOpt_orig_comp.mat
clear step

is_fullTrainingLength = 0;
lidx = 880;
ridx = 2523;

% External system parameter setting
abs_value = 3;
abs_aalue = 0.45;
envIndependState.v_ave = ceil(vave_formal./abs_value).*abs_value';
envIndependState.a_ave = floor(a_ave_formal./abs_aalue).*abs_aalue';
envIndependState.HessPwrOpt = BattOptPwr(2:end);

if is_fullTrainingLength
    envIndependState.startingStep = 1;
    envIndependState.shutdownJudgement = length(envIndependState.HessPwrOpt);
else
    envIndependState.startingStep = lidx;
    envIndependState.shutdownJudgement = ridx;
end

envIndependState.sc_discharge_limit = sc_discharge_limit;
envIndependState.sc_charge_limit = sc_charge_limit;
envIndependState.sc_E = sc_E;
envIndependState.Sc_pwr_upper_lmt = Sc_pwr_upper_lmt;

envIndependState.BattSocLowerLimit = BattSocLowerLimit;
envIndependState.BattSocUpperLimit = BattSocUpperLimit;
envIndependState.Q_batt = Q_batt;
envIndependState.BattUoc = BattUoc;
envIndependState.Bat_power_max_kW = Bat_power_max_kW;
envIndependState.Batt_sf = Batt_sf;
envIndependState.Batt_sf_mean = mean(Batt_sf);

envIndependState.ssoc = sc_soc_init;
envIndependState.bsoc = BattSocInit;


% Obs / Action initialization
ObservationInfo = rlNumericSpec([2 1]);
ObservationInfo.Name = 'Vehicle DCSF States';
ObservationInfo.Description = 'v_dcsf, a_dcsf';

ActionInfo = rlFiniteSetSpec(transpose(0.1:0.2:0.9));
ActionInfo.Name = 'Action Regarding the Sc SOC_ref';

ResetHandle = @() myResetFunction(envIndependState);
StepHandle = @(Action,LoggedSignals) myStepFunction(Action,LoggedSignals,envIndependState);

env = rlFunctionEnv(ObservationInfo,ActionInfo,StepHandle,ResetHandle);

obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

rng(0)

%% Agent training option

% Define the deep neural network for the Q-function approximator
net = [
    featureInputLayer(obsInfo.Dimension(1))
    fullyConnectedLayer(20)
    reluLayer
    fullyConnectedLayer(length(actInfo.Elements))];

net = dlnetwork(net);
summary(net)
plot(net)
critic = rlVectorQValueFunction(net,obsInfo,actInfo);

% Create the DQN agent
agent = rlDQNAgent(critic);

% Set the hyperparameters for the DQN agent
agent.AgentOptions.UseDoubleDQN = false;
agent.AgentOptions.TargetSmoothFactor = 1;
agent.AgentOptions.TargetUpdateFrequency = 4;
agent.AgentOptions.ExperienceBufferLength = 1e5;
agent.AgentOptions.MiniBatchSize = 256;
agent.AgentOptions.CriticOptimizerOptions.LearnRate = 1e-3;
agent.AgentOptions.CriticOptimizerOptions.GradientThreshold = 1;

% Define the training options for the DQN agent
trainOpts = rlTrainingOptions(...
    MaxEpisodes=100000, ...
    MaxStepsPerEpisode=8000, ...
    Verbose=false, ...
    Plots="training-progress",...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue=0); 

disp("CORE DEPENDENCY LOADED COMPLETE WITH NO ERROR.")

% Train the DQN agent using the environment defined in the provided code
trainingStats = train(agent,env,trainOpts);



%% Function part

function [InitialObservation,LoggedSignals] = myResetFunction(envIndependState)
    curr_state = envIndependState.startingStep;
    v_ave_init = envIndependState.v_ave(curr_state);
    a_ave_init = envIndependState.a_ave(curr_state);
    P_h_init = envIndependState.HessPwrOpt(curr_state);
    
    LoggedSignals.ssoc = envIndependState.ssoc;
    LoggedSignals.bsoc = envIndependState.bsoc;
    LoggedSignals.step = curr_state;

    InitialObservation = [v_ave_init; a_ave_init];
end


function [Observation,Reward,IsDone,LoggedSignals] = ...
    myStepFunction(Action,LoggedSignals,envIndependState)
    
    % Actual logic should be:
    % (s, a) of current step, Action -> a, LoggedSignals -> s.
    % Observation is the Env feedback -> s'.
    % The obs in this case won't be influenced by the current state, action.
    % Only the reward is the value resulted by the adopting of the action.

    curr_step = LoggedSignals.step;
    ssoc = LoggedSignals.ssoc;
    bsoc = LoggedSignals.bsoc;

    sc_discharge_limit = envIndependState.sc_discharge_limit;
    sc_charge_limit = envIndependState.sc_charge_limit;
    sc_E = envIndependState.sc_E;
    Sc_pwr_upper_lmt = envIndependState.Sc_pwr_upper_lmt;

    BattSocLowerLimit = envIndependState.BattSocLowerLimit;
    BattSocUpperLimit = envIndependState.BattSocUpperLimit;
    Q_batt = envIndependState.Q_batt;
    BattUoc = envIndependState.BattUoc;
    Bat_power_max_kW = envIndependState.Bat_power_max_kW;
    Batt_sf = envIndependState.Batt_sf;
    Batt_sf_mean = envIndependState.Batt_sf_mean;

    v_ave = envIndependState.v_ave(curr_step);
    a_ave = envIndependState.a_ave(curr_step);
    P_h = envIndependState.HessPwrOpt(curr_step);
    
    Observation = [v_ave; a_ave];

    % Reward calculation
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

        % fmincon solving block
        ssoc_ref = Action;

        sqp_state = [];
        sqp_state = [bsoc; ssoc; ssoc_ref; P_h];

        alpha_set = transpose(linspace(lb_state,ub_state,200));
        cost_list = rwd_est(alpha_set, sqp_state);
        [opt_cost, idx] = min(cost_list(:,3));
        alpha_hess = alpha_set(idx);
        
        
        P_batt_opt = P_h * alpha_hess;
        P_sc_opt = P_h * (1-alpha_hess);
        
        [bsoc_next, Batt_sf_opt, Batt_aheff_opt] = ...
            Batt_state_transf(bsoc, P_batt_opt);
        
        ssoc_next = Sc_state_transf(ssoc, P_sc_opt);

        LoggedSignals.ssoc = ssoc_next;
        LoggedSignals.bsoc = bsoc_next;

    else

        [bsoc_next, Batt_sf_opt, Batt_aheff_opt] = ...
            Batt_state_transf(bsoc, 0);
        ssoc_next = ssoc;

        LoggedSignals.ssoc = ssoc_next;
        LoggedSignals.bsoc = bsoc_next;

    end

    % Rewarf Claculation
    IntFactor = 40;
    PreExpFactor = 2;
    if abs(P_h) >= 6
       Reward = ((-1)*IntFactor*Batt_sf_mean) / ...
           max([exp(PreExpFactor*(Batt_sf(curr_step)-Batt_sf_opt)), 0.001]);
    else
        Reward = -1;
    end
    

    % Time Step Update
    LoggedSignals.step = curr_step + 1;
    IsDone = curr_step == envIndependState.shutdownJudgement;

end


