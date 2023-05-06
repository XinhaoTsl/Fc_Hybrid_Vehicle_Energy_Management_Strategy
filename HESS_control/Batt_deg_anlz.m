% run SL_Markov_TestBuck.m

global Bat_ori_SOC2
global Bat_ori_Uoc_dis_V
global Bat_ori_Uoc_chg_V
global sc_soc_acceptableRange

% -0.1 <- action -> + 0.1
sc_soc_acceptableRange = 0.06;  

load Batt_soc2uoc.mat


opt_len = length(BattOptPwr);

action_list = linspace(sc_discharge_limit, sc_charge_limit, 90);


for step = 1:opt_len

    [soc_est(step), Batt_sf_log(step), Batt_Aheff(step)] = ...
        Batt_state_transf(BattSocOpt(step), BattOptPwr(step));

end

Batt_Aheff_acc = tril(ones(length(Batt_Aheff))) * Batt_Aheff;

% figure
% yyaxis left
% plot(Batt_sf_log)
% 
% yyaxis right
% plot(Batt_Aheff_acc,'r',LineWidth=1.5)
% 
% Batt_Aheff_acc(end) / nbl_std
% 
% figure
% hold on
% plot(soc_est)
% plot(BattSocOpt)
% hold off


test_point = linspace(0.5,3,100);
for i = 1:length(test_point)
    p_verify(i) = Batt_penalty(test_point(i))
end

figure
hold on
plot(p_verify)
plot(test_point)
hold off

set(gca,'XTick',0:20:100);
set(gca,'XTicklabel',{'0.5','1.0','1.5','2.0','2.5', '3.0'})

verf_set = linspace(0.3, 0.6, 500);
ref_soc = 0.45;

for i = 1:length(verf_set)
    p_sc(i) = sc_penalty(verf_set(i), ref_soc);
end

figure
hold on
plot(p_sc)
set(gca,'XTick',0:100:500);
set(gca,'XTicklabel',{'0.3','0.36','0.42','0.48','0.54','0.6'})
