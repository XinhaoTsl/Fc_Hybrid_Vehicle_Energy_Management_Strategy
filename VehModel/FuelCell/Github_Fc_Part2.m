

i = 0:0.02:1.8;
t_m = 125;
T = 80;
RH = 70;

figure(1)
title('Fuel cell voltage: t_m = 125 \mum, T = 80 �C, RH = 70 %')
xlabel('Current density [A/cm^2]')
ylabel('[V]')
hold all
grid on


figure(2)
title('Fuel cell power density: t_m = 125 \mum, T = 80 �C, RH = 70 %')
xlabel('Current density [A/cm^2]')
ylabel('[W/cm^2]')
hold all
grid on

for p = [1 2 3]
    V = V_fc(i,p,T,RH,t_m);
    figure(1),plot(i,V,'linewidth',2)
    figure(2),plot(i,i.*V,'linewidth',2)
end
figure(1),legend('p = 1 bar','p = 2 bar','p = 3 bar')
figure(2),legend('p = 1 bar','p = 2 bar','p = 3 bar')
    