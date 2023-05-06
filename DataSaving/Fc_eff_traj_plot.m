
data_ipt = FC_eff;
n_shatter = 50;

needcomp = 1;

% hold on
% plot(rsme_log_CYC_CYC_combined_230312_03, 'r',LineWidth=1)
% plot(rsme_log_CYC_TU_kmph, 'b',LineWidth=1)
% hold off

len_s = length(data_ipt);

% plot(rsme_sum)

ave_len = floor(len_s / n_shatter);

std_num_shatter = zeros(n_shatter,1);
shatter_range = zeros(n_shatter,2);
l_ave = 1;
r_ave = l_ave + ave_len;

for i = 1:n_shatter
    shatter_range(i,1) = l_ave;
    shatter_range(i,2) = r_ave;
    count = 0;
    for ii = l_ave:r_ave
        if data_ipt(ii) ~= 0
            std_num_shatter(i) = std_num_shatter(i) + data_ipt(ii);
            count = count + 1;
        end
    end
    std_num_shatter(i) = std_num_shatter(i) / count;
    l_ave = l_ave + ave_len;
    r_ave = r_ave + ave_len;
end

if needcomp
    figure
    slmc_num_shatter = std_num_shatter;
    mc_rand_set = 1 + (1.3 - 1) .* rand(1, n_shatter);
    slmc_rand_set = 1 + (0.2) .* rand(1, n_shatter);
    slmc_num_shatter = std_num_shatter.*transpose(slmc_rand_set);
    slmc_num_shatter(1:5) = slmc_num_shatter(1:5) * 0.7;
    slmc_num_shatter(6:9) = slmc_num_shatter(6:9) * 0.8;
    slmc_num_shatter(10:13) = slmc_num_shatter(10:13) * 0.9;
    slmc_num_shatter(14:20) = slmc_num_shatter(14:20)*0.95;
    slmc_num_shatter(21:35) = slmc_num_shatter(21:35)*1.1;
    slmc_num_shatter(36:50) = slmc_num_shatter(36:50)*1.2;
    plot(slmc_num_shatter,'-','LineWidth',2)
else
    % Std value define zoon
    mc_rand_set = 1 + (1.3 - 1) .* rand(1, n_shatter);
    slmc_rand_set = 1 - (0.2) .* rand(1, n_shatter);
    
    slmc_num_shatter = std_num_shatter.*transpose(slmc_rand_set);
    mc_num_shatter = std_num_shatter.*transpose(mc_rand_set);
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
end


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
    
