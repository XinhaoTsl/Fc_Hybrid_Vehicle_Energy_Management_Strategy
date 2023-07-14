
run Assemble_ThetaTable.m

[vstd_formal, vave_formal, a_ave_formal] = Fun_SLMP(DrvCycKph);
run CycTypeRgz.m

figure
yyaxis left
plot(Fixedct)

yyaxis right
plot(DrvCycKph(:,2))



