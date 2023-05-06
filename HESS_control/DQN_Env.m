%% Powered by Xinhaoxu_Tesla -- HESS_DQN Test Env
%  Run configuration first

run Config_c230321.m
load 230415_Pure_BattPwrOpt_orig_comp.mat
clear Batt_sf
autoplot_enable = 1;

HessPwrOpt = BattOptPwr(2:end);
HessCycLen = length(HessPwrOpt);

for step = 1:HessCycLen
    [soc_next, Batt_sf(step), ah_eff] = ...
        Batt_state_transf(BattSocOpt(step), BattOptPwr(step)); 
end

global nbl_std
nbl_btm = (0.5*2694.5+6022.2)*exp((-31700+152.5)/(8.314*298.15));
nbl_std = (20/nbl_btm)^(1/0.57);


Batt_sf_mean = mean(Batt_sf);

for step = 1:HessCycLen
    
    % Env input
    P_h = HessPwrOpt(step);

    % Condition initialization
    if step < 2

        % The current battery state.
        % Taken as the base of transf Batt_state(t) -> Batt_state(t+1).
        bsoc(step) = BattSocInit;

        % The current Sc state.
        % Taken as the base of the transf Sc_state(t) -> Sc_state(t).
        ssoc(step) = sc_soc_init;
    end

    
    
    
    %% Action Generator
    
%     action_list = transpose(linspace(0.15,0.85,5));
action_list = transpose(linspace(0.3,0.7,5));
    
    % Assume the action "ssoc_ref" already generated.
    % ssoc_ref = 0.9 - step*0.8/HessCycLen;

    if vave_formal(step) >= 26
        ssoc_ref(step) = action_list(1);
    elseif vave_formal(step) >= 20 && vave_formal(step) < 26
        ssoc_ref(step) = action_list(2);
    elseif vave_formal(step) >= 12 && vave_formal(step) < 20
        ssoc_ref(step) = action_list(3);
    elseif vave_formal(step) >= 4 && vave_formal(step) < 12
        ssoc_ref(step) = action_list(4);
    elseif vave_formal(step) >= 0 && vave_formal(step) < 4
        ssoc_ref(step) = action_list(5);
    end

% ssoc_ref(step) = action_list(3);
    

    %% Reward Estimation
    if abs(P_h) > 0
        
        if P_h > 0.001 
            ssoc_lmt(step) = 1-abs(ssoc(step)-sc_discharge_limit)*sc_E/max([0.001, P_h * 1000]);
            bsoc_lmt(step) = abs(bsoc(step)-BattSocLowerLimit)*Q_batt*BattUoc/max([0.001, P_h * 1000]);
        else
            ssoc_lmt(step) = 1-(-1)*abs(ssoc(step)-sc_charge_limit)*sc_E/min([-0.001, P_h * 1000]);
            bsoc_lmt(step) = (-1)*abs(bsoc(step)-BattSocUpperLimit)*Q_batt*BattUoc/min([-0.001, P_h * 1000]);
        end

        batt_pwr_lmt(step) = Bat_power_max_kW/max([0.001, abs(P_h)]);
        sc_pwr_lmt(step) = 1 - Sc_pwr_upper_lmt/max([0.001, abs(P_h)]);
        
        lb_state(step) = max([ssoc_lmt(step), sc_pwr_lmt(step), 0]);
        ub_state(step) = min([bsoc_lmt(step), batt_pwr_lmt(step), 1]);


        % fmincon solving block
        sqp_state = [];
        sqp_state = [bsoc(step); ssoc(step); ssoc_ref(step); P_h];

        % ----------SQP optimal solver ---------
%         x0 = 0.5;
%         options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
%         [x, y] = fmincon(@(x) rwd_est(x, sqp_state), ...
%             x0, [], [], [], [], lb_state(step), ub_state(step), [], options);
%         alpha_hess(step) = x;
        

        % ---------- iteration solver ---------
        alpha_set = transpose(linspace(lb_state(step),ub_state(step),200));
        cost_list = rwd_est(alpha_set, sqp_state);
        [opt_cost, idx] = min(cost_list(:,3));
        alpha_hess(step) = alpha_set(idx);
        
        
        P_batt_opt(step) = P_h * alpha_hess(step);
        P_sc_opt(step) = P_h * (1-alpha_hess(step));
        
        [bsoc_next, Batt_sf_opt(step), Batt_aheff_opt(step)] = ...
            Batt_state_transf(bsoc(step), P_batt_opt(step));
        bsoc(step+1) = bsoc_next;
        
        ssoc_next = Sc_state_transf(ssoc(step), P_sc_opt(step));
        ssoc(step+1) = ssoc_next;

    else
        batt_pwr_lmt(step) = 1;
        bsoc_lmt(step) = 1;
        sc_pwr_lmt(step) = 0;
        ssoc_lmt(step) = 0;
        lb_state(step) = max([ssoc_lmt(step), sc_pwr_lmt(step), 0]);
        ub_state(step) = min([bsoc_lmt(step), batt_pwr_lmt(step), 1]);

        [bsoc_next, Batt_sf_opt(step), Batt_aheff_opt(step)] = ...
            Batt_state_transf(bsoc(step), 0);

        bsoc(step+1) = bsoc_next;
        ssoc(step+1) = ssoc(step);
        alpha_hess(step) = 1;
    end

    % Rewarf Claculation
    IntFactor = 40;
    PreExpFactor = 3.5;
    if abs(P_h) >= 6
        Reward(step) = ((-1)*IntFactor*Batt_sf_mean) / ...
            max([exp(PreExpFactor*(Batt_sf(step)-Batt_sf_opt)), 0.001]);
    else
        Reward(step) = -1;
    end

    alpha_range(step) = ub_state(step) - lb_state(step);
    curr = step
end
reward = (-1) * sum(Batt_aheff_opt)

%% Process visualization
if autoplot_enable
    run Init_data_anlz.m; end
disp("Mission completed.")
