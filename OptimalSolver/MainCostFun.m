%J_obj=ahpha*J11+alpha*J12;

function [output] = MainCostFun(X)

global BattSocRef BattSocLog FcPwrLog
global cfwf PredLen usd2rmb
global Cost

FcPwrKw = X(1:(PredLen+1),1);
BattPwrKw = X((PredLen+1)+1:2*(PredLen+1),1);
alpha = cfwf;


%% Hydrogen Consumption Rate
%J11=Pfc/(eff_fc*LHV_H2)
FC_ori_power_kW = [0,2,5,7.500000000000000,10,20,30,40,50];
FC_ori_fuel_rate_gps = [0,0.050505050505051,0.084688346883469,0.117260787992495,0.149075730471079,0.279642058165548,0.423011844331641,0.593119810201661,0.820209973753281];

FcHydconRmb = 30/1000 * interp1(FC_ori_power_kW, FC_ori_fuel_rate_gps, FcPwrKw);


%% Fuelcell Degradation Rate

% HighFcOptPwrDegRate
alpha_h = 10;   %10e-6V/h
u_eol = 100000;   %10e-6V
tDegTable = [zeros(1,3),linspace(0,0.13,47)];
p_stack = 50*93*usd2rmb;

if mean(FcPwrKw) >= 40
    hfpdr = FcPwrKw * (alpha_h*p_stack/u_eol)/3600;
else
    hfpdr = 0;
end

% LowFcOptPwrDegRate
if mean(FcPwrKw) <= 10
    alpha_l = 8.66;   %10e-6V/h
    lfpdr = FcPwrKw * (alpha_l*p_stack/u_eol)/3600;
else
    lfpdr = 0;
end

% ShiftFcDegRate
FcPwrLogSet = [FcPwrLog;FcPwrKw(1:PredLen)];
DeltaFcPwr = FcPwrKw - FcPwrLogSet;
% sfpdr = DeltaFcPwr .* interp1(1:50,tDegTable,DeltaFcPwr) *93*50*usd2rmb/(2*100000);
sfpdr = 0;

FcDegRmb = hfpdr + lfpdr + sfpdr;


%% Battery Electricity Power Consumption Rate

BattUoc = 320;
Bat_ori_cap_max_Ah = 20.7;

% Soc Drop pre step

DeltaSocPrePwrKw = 1000 / (Bat_ori_cap_max_Ah * 3600 * BattUoc);

SocDrop = tril(DeltaSocPrePwrKw*ones(PredLen+1))*BattPwrKw;
BattSocOpt = BattSocLog*ones(PredLen+1,1) - SocDrop;

BattSocOfst = abs(BattSocOpt-BattSocRef);


%% BattDeg Cost

Price_batcell_RMBpercell=26; bl_nom=92342; Bat_num_pa=9; Bat_num_se=97;
 
if BattSocOpt<=0.45 
    b00=0.4129; b10=0.5561; b01=0.09967; b20=-0.2877; b11=0.03978;
    b02=0.006167; b30=-0.02986; b21=0.046; b12=0.004712;

    BattCellDeg = b00+b10*BattSocOpt+b01*BattPwrKw+b20*BattSocOpt.^2+b11*...
        BattSocOpt.*BattPwrKw+b02*BattPwrKw.^2+b30*BattSocOpt.^3+b21*...
        BattSocOpt.^2 .*BattPwrKw+b12*BattSocOpt.*BattPwrKw.^2;

else
    c00=0.1742; c10=0.6602; c01=0.08125; c20=-0.2258; c11=0.007218;
    c02=0.004079; c30=-0.02605; c21=0.04045; c12=0.00418;

    BattCellDeg = c00+c10*BattSocOpt+c01*BattPwrKw+c20*BattSocOpt.^2+c11*...
        BattSocOpt.*BattPwrKw+c02*BattPwrKw.^2+c30*BattSocOpt.^3+c21*...
        BattSocOpt.^2 .*BattPwrKw+c12*BattSocOpt.*BattPwrKw.^2;
end

BattDeg = BattCellDeg*Bat_num_pa*Bat_num_se*Price_batcell_RMBpercell/(3600*bl_nom);


%% J_obj
alpha = 0.5;

Cost = alpha*(1.2*sum(FcHydconRmb+FcDegRmb)) + ...
       (1-alpha)*(sum(0*20*BattDeg+3000*BattSocOfst))



%% output
output = Cost;


end