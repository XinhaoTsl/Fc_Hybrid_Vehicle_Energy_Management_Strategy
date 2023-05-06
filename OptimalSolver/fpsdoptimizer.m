function [output] = fpsdoptimizer(X)

global FTP FTSOC BattSocUpperLimit;
usd2rmb = 7;

fcpdr = X;   % Fuelcell OutputPwr DropRate (FCPDR)
step = floor(FTP/fcpdr);

DropStepLen = step;


DropTable = tril((-1)*fcpdr*ones(DropStepLen))*(fcpdr*ones(DropStepLen,1));


%% Hydrogen Consumption Rate
FC_ori_power_kW = [0,2,5,7.500000000000000,10,20,30,40,50];
FC_ori_fuel_rate_gps = [0,0.050505050505051,0.084688346883469,0.117260787992495,0.149075730471079,0.279642058165548,0.423011844331641,0.593119810201661,0.820209973753281];

FcHydconRmb = 30/1000 * sum(interp1(FC_ori_power_kW, FC_ori_fuel_rate_gps, DropTable));


%% Fuelcell Degradation Rate

% HighFcOptPwrDegRate
alpha_h = 10;   %10e-6V/h
alpha_l = 8.66;   %10e-6V/h
u_eol = 100000;   %10e-6V
p_stack = 50*93*usd2rmb;

t_hfpdr = zeros(DropStepLen,1);
t_lfpdr = zeros(DropStepLen,1);

for i = 1:DropStepLen
    if DropTable(i) >= 40   % HighFcOptPwrDegRate
        t_hfpdr(i,1) = DropTable(i) * (alpha_h*p_stack/u_eol)/3600;
        t_lfpdr(i,1) = 0;
    elseif DropTable(i) <= 10   % LowFcOptPwrDegRate
        t_lfpdr(i,1) = DropTable(i) * (alpha_l*p_stack/u_eol)/3600;
        t_hfpdr(i,1) = 0;
    else
        t_lfpdr(i,1) = 0;
        t_hfpdr(i,1) = 0;
    end
end

hfpdr = sum(t_hfpdr);
lfpdr = sum(t_lfpdr);

sfpdr = fcpdr * DropStepLen * (0.0441/100000)*93*50*usd2rmb/(1000*500);

FcDegRmb = hfpdr + lfpdr + sfpdr;


%% Battery State Operation

BattUoc = 320;
Bat_ori_cap_max_Ah = 20.7;

% Soc Drop pre step
DeltaSocPrePwrKw = 1000 / (Bat_ori_cap_max_Ah * 3600 * BattUoc);
SocIncreaseTable = tril(DeltaSocPrePwrKw*ones(DropStepLen))*(fcpdr*ones(DropStepLen,1));
SocStateTable = 100*FTSOC*ones(DropStepLen,1) + SocIncreaseTable;

socpf = [zeros(1,78),0:1:4,5:95/16:100];
SocCost = sum(interp1(1:100,socpf,SocStateTable));


%% J_obj
Cost = FcHydconRmb + FcDegRmb + SocCost;


%% output
output = Cost; % Fuelcell


end