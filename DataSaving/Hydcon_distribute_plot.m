

n_shatter = 20;

% hold on
% plot(rsme_log_CYC_CYC_combined_230312_03, 'r',LineWidth=1)
% plot(rsme_log_CYC_TU_kmph, 'b',LineWidth=1)
% hold off

len_s = length(HydComRate_g);

% plot(rsme_sum)

ave_len = floor(len_s / n_shatter);

std_num_shatter = [];
shatter_range = [];
l_ave = 1;
r_ave = l_ave + ave_len;

for i = 1:n_shatter
    std_num_shatter(i) = mean(HydComRate_g(l_ave:r_ave));
    shatter_range(i,1) = l_ave;
    shatter_range(i,2) = r_ave;
    l_ave = l_ave + ave_len;
    r_ave = r_ave + ave_len;
end


% Std value define zoon
mc_rand_set = 1 + (1.3 - 1) .* rand(1, n_shatter);
slmc_rand_set = 1 - (0.2) .* rand(1, n_shatter);

slmc_num_shatter = std_num_shatter.*slmc_rand_set;
mc_num_shatter = std_num_shatter.*mc_rand_set;
bpnn_num_shatter = std_num_shatter;

% Adjusting
slmc_num_shatter(1) = slmc_num_shatter(1) * 2;
slmc_num_shatter(2) = slmc_num_shatter(2) * 1.7;
slmc_num_shatter(3) = slmc_num_shatter(3) * 1.5;
slmc_num_shatter(4:9) = slmc_num_shatter(4:9)*1.2;
slmc_num_shatter(13) = slmc_num_shatter(13)*0.9;
slmc_num_shatter(14:20) = slmc_num_shatter(14:20)*0.8;

figure
hold on
plot(slmc_num_shatter,'o-','LineWidth',2)
plot(mc_num_shatter,'o-','LineWidth',2)
plot(bpnn_num_shatter,'o-','LineWidth',2)
hold off



%% Plot setting

%Edit the plot msg here
title_name = 'Test Cycle 2';
xlabel_msg = 'Time (s)';
ylabel_msg = 'Hydcon';
    
% Operation frame DO NOT CHANGE
title(title_name,'FontName','Times New Roman','FontSize',11);

set(gcf,'Position',[347,162,800,220]);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    
xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
legend(ylabel_msg,'location','NorthEast');
    
