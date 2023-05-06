
% Nernst potential
t = [20 50 80]+273.15  % [K] Values of stack temperature
p = 1:0.5:3 % pressure at the cathode and the anode
for j = 1:length(t)
    for k = 1:length(p)
        p_O2 = 0.21 * p(k); % [bar] oxygen partial pressure
        p_H2 = 1.00 * p(k); % [bar] hydrogen partial pressure
        T_fc = t(j);
        % Nernst Potential [V]
        E(j,k) = 1.229 - 0.85*1e-3*(T_fc-298.15)+4.3085*1e-5*T_fc*(log(p_H2/101325)+1/2*log(p_O2/101325));
    end
end
clear

% Activation overvoltage 1
i = 0:0.02:1.8; % [A/cm^2] current density
figure
title('Activation Overvoltage - T = 80 �C')
xlabel('Current density [A/cm^2]')
ylabel('[V]')
hold all
grid on

for T_fc = [80]+273.15  % [K] Values of stack temperature
    for p = [1:0.5:3] % [bar] pressure at the cathode and the anode
        p_H2 = p;
        p_O2 = 0.21*p;
        p_ca = p;
        p_sat = 0.01*10^(-1.69e-10*T_fc^4 + 3.85e-7*T_fc^3 - 3.39e-4*T_fc^2 + 0.143*T_fc - 20.92); %[bar]
        v_0 = 0.279-8.5e-4*(T_fc-298.15)+4.308e-5*T_fc*(log((p_ca-p_sat)/1.01325)+1/2*log(0.1173*(p_ca-p_sat)/1.01325));
        v_a = (-1.618e-5*T_fc+1.618e-2)*(p_O2/0.1173+p_sat)^2 + (1.8e-4*T_fc-0.166)*(p_O2/0.1173+p_sat) + (-5.8e-4*T_fc+0.5736);
        c1 = 10;

        v_act = v_0 + v_a*(1-exp(-c1*i));
        plot(i,v_act,'linewidth',2)
    end
end
legend('p_{ca} = 1 bar','p_{ca} = 1.5 bar','p_{ca} = 2 bar','p_{ca} = 2.5 bar','p_{ca} = 3 bar','Location','SouthEast')
clear

% Activation overvoltage 2
i = 0:0.02:1.8; % [A/cm^2] current density
figure
title('Activation Overvoltage - p = 2 bar')
xlabel('Current density [A/cm^2]')
ylabel('[V]')
hold all
grid on

for T_fc = [20 50 80]+273.15  % [K] Values of stack temperature
    for p = 2 % pressure at the cathode and the anode
        p_O2 = 0.21*p;
        p_H2 = p;
        p_ca = p;
        p_sat = 0.01*10^(-1.69e-10*T_fc^4 + 3.85e-7*T_fc^3 - 3.39e-4*T_fc^2 + 0.143*T_fc - 20.92);
        v_0 = 0.279-8.5e-4*(T_fc-298.15)+4.308e-5*T_fc*(log((p_ca-p_sat)/1.01325)+1/2*log(0.1173*(p_ca-p_sat)/1.01325));
        v_a = (-1.618e-5*T_fc+1.618e-2)*(p_O2/0.1173+p_sat)^2 + (1.8e-4*T_fc-0.166)*(p_O2/0.1173+p_sat) + (-5.8e-4*T_fc+0.5736);
        c_1 = 10;

        v_act = v_0 + v_a*(1-exp(-c_1*i));
        plot(i,v_act,'linewidth',2)
    end
end
legend('T = 20 �C','T = 50 �C','T = 80 �C','Location','SouthEast')
clear

% Ohmic loss - 1
i = 0:0.02:1.8; % [A/cm^2] current density
figure
title('Ohmic overvoltage - T = 80 �C and \lambda_m = 14 (RH = 100%)')
xlabel('Current density [A/cm^2]')
ylabel('[V]')
hold all
grid on
for T_fc = [80]+273.15  % [K] Values of stack temperature
    for t_m = [100 150]/10000 % [cm] membrane thickness
        for la_m = [14] % index of relative humidity

            b11 = 0.005139;
            b12 = 0.00326;
            b2 = 350; % K
            s_m = (b11*la_m-b12)*exp(b2*(1/303-1/T_fc));

            R_ohm = t_m/s_m;
            v_ohm = i*R_ohm;
            plot(i,v_ohm,'linewidth',2)
        end
    end
end
legend('t_m = 100 \mum','t_m = 150 \mum')
clear

% Ohmic loss - 2
i = 0:0.02:1.8; % [A/cm^2] current density
figure
title('Ohmic overvoltage - T = 80 �C and t_m = 125 \mum')
xlabel('Current density [A/cm^2]')
ylabel('[V]')
hold all
grid on
for T_fc = [80]+273.15  % [K] Values of stack temperature
    for t_m = [125]/10000 % [cm] membrane thickness
        for la_m = [0.20 0.50 0.70 1]*14 % index of relative humidity

            b11 = 0.005139;
            b12 = 0.00326;
            b2 = 350; % K
            s_m = (b11*la_m-b12)*exp(b2*(1/303-1/T_fc));

            R_ohm = t_m/s_m;
            v_ohm = i*R_ohm;
            plot(i,v_ohm,'linewidth',2)
        end
    end
end
legend('RH = 20 %','RH = 50 %','RH = 70 %','RH = 100 %')
clear

% Ohmic loss - 3
i = 0:0.02:1.8; % [A/cm^2] current density
figure
title('Ohmic overvoltage - t_m = 125 \mum and RH = 7%')
xlabel('Current density [A/cm^2]')
ylabel('[V]')
hold all
grid on
for T_fc = [20 50 80]+273.15  % [K] Values of stack temperature
    for t_m = [125]/10000 % [cm] membrane thickness
        for la_m = 0.07*14; % index of relative humidity

            b11 = 0.005139;
            b12 = 0.00326;
            b2 = 350; % K
            s_m = (b11*la_m-b12)*exp(b2*(1/303-1/T_fc));

            R_ohm = t_m/s_m;
            v_ohm = i*R_ohm;
            plot(i,v_ohm,'linewidth',2)
        end
    end
end
legend('T_f_c = 20 �C','T_f_c = 50 �C','T_f_c = 80 �C')
clear

% Concentration loss - 1
i = 0:0.02:1.8; % [A/cm^2] current density
figure
title('Concentration overvoltage - T = 80 �C')
xlabel('Current density [A/cm^2]')
ylabel('[V]')
hold all
grid on
c3 = 2;
i_max = 2.2; %[A/cm^2]
for T_fc = [80]+273.15  % [K] Values of stack temperature
    for p = [1:0.5:3] % [bar] pressure at the cathode and the anode
        p_O2 = 0.21*p;
        p_sat = 10^(-1.69e-10*T_fc^4 + 3.85e-7*T_fc^3 - 3.39e-4*T_fc^2 + 0.143*T_fc - 20.92);
        if (p_O2/0.1173+p_sat)<2
            c2 = (7.16e-4*T_fc - 0.622)*(p_O2/0.1173+p_sat) + (-1.45e-3*T_fc+1.68);
        elseif (p_O2/0.1173+p_sat)>=2
            c2 = (8.66e-5*T_fc - 0.068)*(p_O2/0.1173+p_sat) + (-1.6e-4*T_fc+0.54);
        end
        v_conc = i.*(c2*i/i_max).^c3;
        plot(i,v_conc,'linewidth',2)
    end
end
legend('p_{ca} = 1 bar','p_{ca} = 1.5 bar','p_{ca} = 2 bar','p_{ca} = 2.5 bar','p_{ca} = 3 bar','Location','SouthEast')
clear

% Concentration loss - 2
i = 0:0.02:1.8; % [A/cm^2] current density
figure
title('Concentration overvoltage - p_{ca} = 2 bar')
xlabel('Current density [A/cm^2]')
ylabel('[V]')
hold all
grid on
c3 = 2;
i_max = 2.2; %[A/cm^2]
for T_fc = [20 50 80]+273.15  % [K] Values of stack temperature
    for p = [2] % [bar] pressure at the cathode and the anode
        p_O2 = 0.21*p;
        p_sat = 10^(-1.69e-10*T_fc^4 + 3.85e-7*T_fc^3 - 3.39e-4*T_fc^2 + 0.143*T_fc - 20.92);
        if (p_O2/0.1173+p_sat)<2
            c2 = (7.16e-4*T_fc - 0.622)*(p_O2/0.1173+p_sat) + (-1.45e-3*T_fc+1.68);
        elseif (p_O2/0.1173+p_sat)>=2
            c2 = (8.66e-5*T_fc - 0.068)*(p_O2/0.1173+p_sat) + (-1.6e-4*T_fc+0.54);
        end
        v_conc = i.*(c2*i/i_max).^c3;
        plot(i,v_conc,'linewidth',2)
    end
end
legend('T_f_c = 20 �C','T_f_c = 50 �C','T_f_c = 80 �C')
clear