run Config_c230321.m
load 230415_Pure_BattPwrOpt_orig_comp.mat
clear step

abs_value = 3;
abstract_vave = ceil(vave_formal./abs_value).*abs_value;


abs_aalue = 0.45
abstract_a_ave = floor(a_ave_formal./abs_aalue).*abs_aalue;



needslice = 1

if needslice
    lidx = 1200;
    sliceLength = 200;
    ridx = lidx + sliceLength;
else
    lidx = 1;
    ridx = length(vave_formal)
end



figure
subplot(211)
hold on
plot(vave_formal(lidx:ridx))
plot(abstract_vave(lidx:ridx))
hold off

subplot(212)
hold on
plot(a_ave_formal(lidx:ridx))
plot(abstract_a_ave(lidx:ridx))
hold off



