function cost = rwd_est(x, state)

    bsoc = state(1);
    ssoc = state(2);
    ssoc_ref = state(3);
    P_hess = state(4);
    
    P_batt = x .* P_hess;
    P_sc = (1 - x) .* P_hess;
    
    cost1 = Batt_cost(bsoc, P_batt);
    cost2 = 1*Sc_cost(ssoc, ssoc_ref, P_sc);


    cost_main = cost1 + cost2;
    cost = [cost1,cost2,cost_main];
end

