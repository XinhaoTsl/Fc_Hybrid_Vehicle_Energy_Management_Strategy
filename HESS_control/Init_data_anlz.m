global_anlz = 4


lidx = 1500;
slice_len = 90;
ridx = lidx + slice_len;

if global_anlz == 4
figure
    subplot(211)
    title('Sc Soc Traj','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    plot(ssoc_ref,'k',LineWidth=1);
    plot(ssoc,'g',LineWidth=1.5);
    hold off
    ylabel('SOC_s_c','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);

    subplot(212)
    title('Alpha distribution','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    scatter(1:length(alpha_hess),alpha_hess,150,'.')
    
    mean_len = 100;
    count = 1;
    lidx = 1; ridx = mean_len;
    while ridx <= length(alpha_hess)
        alpha_mean(count, 1) = lidx;
        alpha_mean(count, 2) = mean(alpha_hess(lidx:ridx));
        lidx = lidx + mean_len;
        ridx = ridx + mean_len;
        count = count + 1;
    end
    plot(alpha_mean(:,1),alpha_mean(:,2), 'r', LineWidth=2.5)
    hold off
    ylabel('alpha','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);


    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    set(gcf,'Position',[347,162,800,400]);
end



if global_anlz == 0

%     figure
%     title('Batt Soc Traj','FontName','Times New Roman','FontSize',11);
%     set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
%     set(gcf,'Position',[347,162,800,220]);
%     hold on
%     plot(BattSocOpt(lidx:ridx), 'k', LineWidth=1.5)
%     plot(bsoc(lidx:ridx),'b',LineWidth=1.5);
%     hold off
%     legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
%     legend(["Origin","With Sc"],'location','NorthEast');
% 
%     figure
%     title('Batt Ic Comp','FontName','Times New Roman','FontSize',11);
%     set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
%     set(gcf,'Position',[347,162,800,220]);
%     hold on
%     plot(Batt_sf(lidx:ridx), 'k', LineWidth=1.5)
%     plot(Batt_sf_opt(lidx:ridx),'b',LineWidth=1.5);
%     hold off
%     legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
%     legend(["Origin","With Sc"],'location','NorthEast');
%     
%     figure
%     title('SOC offset','FontName','Times New Roman','FontSize',11);
%     set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
%     set(gcf,'Position',[347,162,800,220]);
%     plot(transpose(bsoc(1:end-1)) - BattSocOpt)

    figure
    subplot(2,1,1)
    title('Sc opt pwr','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    plot(transpose(lidx:ridx),HessPwrOpt(lidx:ridx),'k',LineWidth=1.5);
    % plot(P_batt_opt(lidx:ridx),'r',LineWidth=1.5);
    plot(lidx:ridx,P_sc_opt(lidx:ridx),'g',LineWidth=1.5);
    hold off
    ylabel('P_s_c','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
    subplot(2,1,2)
    title('Batt_pwr','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    plot(transpose(lidx:ridx),HessPwrOpt(lidx:ridx),'k',LineWidth=1.5);
    plot(lidx:ridx,P_batt_opt(lidx:ridx),'b',LineWidth=1.5);
    hold off
    ylabel('P_b_a_t_t','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);


elseif global_anlz == 2

    figure
    subplot(2, 2, [1 2])
    yyaxis left
    hold on
    plot_len = length(Reward);
    for i = 1:plot_len
        step_temp = i
        if Reward(i) ~= -1
            scatter(i,Reward(i),100,'.');end
    end
%     scatter(1:length(Reward),Reward,100,'.')

    yyaxis right
    Reward_acc = tril(ones(length(Reward))) * Reward';
    plot(Reward_acc,'-r',LineWidth=1.5)

    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);

    subplot(223)
    yyaxis left
    hold on
    plot(lidx:ridx,Batt_sf(lidx:ridx), '-k', LineWidth=1.5)
    plot(lidx:ridx,Batt_sf_opt(lidx:ridx),'-g',LineWidth=1.5);
    hold off
%     yyaxis right
%     plot(Batt_sf(lidx:ridx) - Batt_sf_opt(lidx:ridx)','-',LineWidth=1.5)

    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);

    subplot(224)
    yyaxis left
    hold on
    plot(lidx:ridx,Reward(lidx:ridx),'-',LineWidth=0.5);

    for i = 1:slice_len
        if Reward(lidx-1 + i) ~= -1
            scatter(lidx-1 + i,Reward(lidx-1 + i),400,'.')
        else
            scatter(lidx-1 + i,Reward(lidx-1 + i),50,'.k')
        end
    end
    
    hold off

    yyaxis right
    plot(lidx:ridx,Batt_sf(lidx:ridx) - Batt_sf_opt(lidx:ridx),'-r',LineWidth=1.5)

    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    set(gcf,'Position',[347,162,800,300]);



elseif global_anlz == 1
    figure
    subplot(5,2,1)
    title('Sc opt pwr','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    plot(HessPwrOpt,'k',LineWidth=1.5);
    % plot(P_batt_opt,'r',LineWidth=1.5);
    plot(P_sc_opt,'g',LineWidth=1.5);
    hold off
    ylabel('P_s_c','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
    subplot(5,2,2)
    title('Batt_pwr','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    plot(HessPwrOpt,'k',LineWidth=1.5);
    plot(P_batt_opt,'b',LineWidth=1.5);
    hold off
    ylabel('P_b_a_t_t','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
    subplot(5,2,3)
    title('Sc Soc Traj','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    plot(ssoc_ref,'k',LineWidth=1);
    plot(ssoc,'g',LineWidth=1.5);
    hold off
    ylabel('SOC_s_c','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
    subplot(5,2,4)
    title('Batt Soc Traj','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    yyaxis left
    hold on
    plot(BattSocOpt, 'k', LineWidth=1.5)
    plot(bsoc,'b',LineWidth=1.5);
    hold off
    yyaxis right
    plot(bsoc - BattSocOpt', LineWidth=1.5)
    ylabel('SOC_b_a_t_t','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
    subplot(5,2,5)
    title('Batt sf Comp','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    plot(Batt_sf, 'k', LineWidth=1.5)
    plot(Batt_sf_opt,'b',LineWidth=1.5);
    hold off
    ylabel('SF_b_a_t_t','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
    subplot(5,2,6)
    aheff_acc = tril(ones(length(Batt_aheff_opt))) * Batt_aheff_opt';
    total_deg = aheff_acc(end)
    title('Batt Aheff','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    plot(Batt_Aheff, 'k', LineWidth=1.5)
    plot(aheff_acc,'b',LineWidth=1.5);
    hold off
    ylabel('Ah_e_f_f','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
    % scatter plot block, heavy time westing, ban this part if not nessary.

    subplot(5,2,[7,8])
    title('Alpha distribution','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    scatter(1:length(alpha_hess),alpha_hess,100,'.')
    
    mean_len = 100;
    count = 1;
    lidx = 1; ridx = mean_len;
    while ridx <= length(alpha_hess)
        alpha_mean(count, 1) = lidx;
        alpha_mean(count, 2) = mean(alpha_hess(lidx:ridx));
        lidx = lidx + mean_len;
        ridx = ridx + mean_len;
        count = count + 1;
    end
    plot(alpha_mean(:,1),alpha_mean(:,2), 'r', LineWidth=2)
    hold off
    ylabel('alpha','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);

    subplot(5,2,[9, 10])
    title('Reward List','FontName','Times New Roman','FontSize',11);
    set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    hold on
    scatter(1:length(Reward),Reward,100,'.')

    mean_len_a = 100;
    count = 1;
    lidx = 1; ridx = mean_len_a;
    while ridx <= length(Reward)
        alpha_mean(count, 1) = lidx;
        temp_set = Reward(lidx:ridx);
        alpha_mean(count, 2) = mean(temp_set(temp_set ~= -1));
        lidx = lidx + mean_len_a;
        ridx = ridx + mean_len_a;
        count = count + 1;
    end
    plot(alpha_mean(:,1),alpha_mean(:,2), 'r', LineWidth=2)

    hold off

%     plot(Reward(10:end),'b',LineWidth=1.5);
    ylabel('alpha','FontName','Times New Roman','FontSize',11,'LineWidth',1.5);



    set(gcf,'Position',[347,162,800,800]);

    Reward_acc = tril(ones(length(Reward))) * Reward';


end