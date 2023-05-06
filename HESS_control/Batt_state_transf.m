function [soc_next, sf, ah_eff] = Batt_state_transf(BattSoc, P_batt)

global nbl_std
global Bat_ori_SOC2
global Bat_ori_Uoc_dis_V
global Bat_ori_Uoc_chg_V
BattCell_current = 2.3;
Q_batt = 18000;

if P_batt >= 0
    voc = interp1(Bat_ori_SOC2, Bat_ori_Uoc_dis_V, BattSoc);
else
    voc = interp1(Bat_ori_SOC2, Bat_ori_Uoc_chg_V, BattSoc);
end

Ic = abs(P_batt)*1000/voc/97/BattCell_current/9;

% Alphabeta Definition Part
if BattSoc > 0.45
    alpha = 2694.5;
    beta = 6022.2;
else
    alpha = 2896.6;
    beta = 7411.2;
end

% Normal Calculation Part
nbl_rt_btm = (BattSoc*alpha+beta)*...
    exp((-31700+152.5*Ic)/(8.314*298.15));
nbl_rt = (20/nbl_rt_btm)^(1/0.57);
    
% severity factor calculation
sf = nbl_std/(nbl_rt); 
ah_eff = (sf*Ic);

soc_next = BattSoc - 1000*P_batt ./ (Q_batt.*voc.*97);

end