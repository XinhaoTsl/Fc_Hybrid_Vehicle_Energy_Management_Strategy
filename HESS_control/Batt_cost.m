function value = Batt_cost(BattSoc, P_batt)
    
    global nbl_std

    BattCell_current = 2.3;
    voc = 3.15;
    
    Ic = abs(P_batt).*1000./voc./97./BattCell_current./9;
    
    % Alphabeta Definition Part
    if BattSoc > 0.45
        alpha = 2694.5;
        beta = 6022.2;
    else
        alpha = 2896.6;
        beta = 7411.2;
    end
    
    % Normal Calculation Part
    nbl_rt_btm = (BattSoc.*alpha+beta).*...
        exp((-31700+152.5.*Ic)./(8.314.*298.15));
    nbl_rt = (20./nbl_rt_btm).^(1/0.57);
        
    % severity factor calculation
    sf = nbl_std./(nbl_rt);
    value = Batt_penalty(sf);

end