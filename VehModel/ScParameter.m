% clear
% clc

load SC_SocTable;
global sc_E
global sc_charge_limit
global sc_discharge_limit

SimTime = inf;

SC_rc = 2000;
SC_rv = 3.2;
SC_iv = 3;
SC_PreChgTime = 100;
Sc_pwr_upper_lmt = 50;

SC_ns = 100;
SC_np = 1;
SC_nm = 2;

N_SC_Series = 1;
N_SC_Parallel = 1;

R_bal = 360;

% sim('Sub_SC_G_based_221015');
% disp(SC_Q(end));

sc_charge_limit = 0.9;
sc_discharge_limit = 0.1;

C_eff  =  SC_rc * SC_np/SC_ns; % Unit: F (Farads)
V_eff =  SC_rv * SC_ns; % Unit: V (Volt)
sc_E = 0.5 * C_eff * V_eff^2;
sc_wh = sc_E / 3600000;

sim('SC_ChgModel')
disp("SC Paremeters Initialization completed");
fprintf('The SC configureation supports max %0.2f discharge time.\n', ...
    sc_msx_discharge_time(end))