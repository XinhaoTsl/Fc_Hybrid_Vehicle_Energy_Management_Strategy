function [is_hwSocExceed] = judge_hwSocExceed(hwSocDr_inc_factor)

    hwSocDr_list = tcp_fine((tcp_fine(:,5) == 3),3).*linerSocDr.*k_soc_hw.*hwSocDr_inc_factor;
    hwSocDr_sum = sum(hwSocDr_list);
    tcp_fine((tcp_fine(:,5) == 3),6) = hwSocDr_list;
    
    is_hwSocExceed = hwSocDr_sum + BattSocInitDrop > BattSocInit - BattSocLowerLimit;
end