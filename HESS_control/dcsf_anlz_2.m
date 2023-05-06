lidx = 1234;
slice = 80;
ridx = lidx + slice;

figure
hold on

plot(DrvCycVps(lidx:ridx,2),'k');
plot(vave_formal(lidx:ridx),'r');

hold off

DrvCyc_a = [0;DrvCycVps(2:end,2) - DrvCycVps(1:end-1,2)];

figure
title('Acc anlz','FontName','Times New Roman','FontSize',11);
yyaxis left
hold on
plot(DrvCyc_a(lidx:ridx),'b',LineWidth=1)
plot(a_ave_formal(lidx:ridx),'-g',LineWidth=2)
hold off


