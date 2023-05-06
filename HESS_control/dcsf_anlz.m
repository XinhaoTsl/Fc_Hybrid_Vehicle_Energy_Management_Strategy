
lidx = 1;
slice = length(DrvCycVps)-1;
ridx = lidx + slice;

DrvCyc_a = [0;DrvCycVps(2:end,2) - DrvCycVps(1:end-1,2)];

figure
title('Acc anlz','FontName','Times New Roman','FontSize',11);
yyaxis left
hold on
plot(DrvCyc_a(lidx:ridx),'b',LineWidth=1)
plot(a_ave_formal(lidx:ridx),'-g',LineWidth=2)
hold off

yyaxis right
plot(vstd_formal(lidx:ridx),'r',LineWidth=1.5)

legend({'Actual Acc', 'Pdt Acc'},'location','NorthEast');


figure
title('Vspd anlz','FontName','Times New Roman','FontSize',11);
yyaxis left
hold on
plot(DrvCycVps(lidx:ridx,2),'b',LineWidth=1)
plot(vave_formal(lidx:ridx),'-r',LineWidth=1.5)
% plot(rsme(lidx:ridx)/5, '-g', LineWidth=1.5)
hold off

yyaxis right
plot(Batt_sf(lidx:ridx))

legend({'Actual Vspd', 'Vstd'},'location','NorthEast');
