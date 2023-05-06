
function V = Github_V(i,p,T,RH,t_m)
  %Data and functions
  % i: Current; p:gas pressure; T:Cell tempurate; 

p_O2 = 0.21 * p; % [bar] oxygen partial pressure
p_H2 = 1.00 * p; % [bar] hydrogen partial pressure
p_ca = p; % [bar] cathode pressure
T_fc = T + 273.15; %[K]


% Nernst Potential
E = 1.229 - 0.85*1e-3*(T_fc-298.15)+4.3085*1e-5*T_fc*(log(p_H2/101325)+1/2*log(p_O2/101325));

% Activation loss
p_sat = 0.01*10^(-1.69e-10*T_fc^4 + 3.85e-7*T_fc^3 - 3.39e-4*T_fc^2 + 0.143*T_fc - 20.92);
v_0 = 0.279-8.5e-4*(T_fc-298.15)+4.308e-5*T_fc*(log((p_ca-p_sat)/1.01325)+1/2*log(0.1173*(p_ca-p_sat)/1.01325));
v_a = (-1.618e-5*T_fc+1.618e-2)*(p_O2/0.1173+p_sat)^2 + (1.8e-4*T_fc-0.166)*(p_O2/0.1173+p_sat) + (-5.8e-4*T_fc+0.5736);
c_1 = 10;
v_act = v_0 + v_a*(1-exp(-c_1*i));

% Ohmic loss
t_m = t_m/10000; %(micron to cm)
b11 = 0.005139;
b12 = 0.00326;
b2 = 350; % K
la_m = RH/100*14;
s_m = (b11*la_m-b12)*exp(b2*(1/303-1/T_fc));
R_ohm = t_m/s_m;
v_ohm = i*R_ohm;

% Concentration loss
c3 = 2;
i_max = 2.2; %[A/cm^2]
if (p_O2/0.1173+p_sat)<2
    c2 = (7.16e-4*T_fc - 0.622)*(p_O2/0.1173+p_sat) + (-1.45e-3*T_fc+1.68);
elseif (p_O2/0.1173+p_sat)>=2
    c2 = (8.66e-5*T_fc - 0.068)*(p_O2/0.1173+p_sat) + (-1.6e-4*T_fc+0.54);
end
v_conc = i.*(c2*i/i_max).^c3;

% Cell voltage
V = E - v_act - v_ohm - v_conc;