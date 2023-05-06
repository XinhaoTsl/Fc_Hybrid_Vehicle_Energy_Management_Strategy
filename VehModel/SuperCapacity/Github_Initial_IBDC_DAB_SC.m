clear
clc

%Standard***************
Vref = 340;
Iref = -6.25;
f = 250000;
P = 1/f;
D = 50;
Vsc=30;
Vrate = 30;
Power=2000;
Sample=1e-8;

cycledelay = 2;
Ts = cycledelay/f;
K = 0.03;
R_load=115.8;
L=19.5e-6;

% MOSFET parameters**************
ron_mosfet_pri = 0.03;
ron_mosfet_sec = 0.03;
ron_body_diode_pri = 0.005;
ron_body_diode_sec = 0.005;
vf_body_diode_pri = 4.5;
vf_body_diode_sec = 4.5;
