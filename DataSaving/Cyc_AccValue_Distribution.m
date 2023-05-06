All_Cyc_Data = [CYC_WVUSUB_kmph;CYC_WVUINTER_kmph;CYC_WVUCITY_kmph;CYC_VAIL2NREL_kmph];
All_Cyc_Data = [All_Cyc_Data;CYC_US06_HWY_kmph;CYC_UNIF01_kmph;CYC_UDDSHDV_kmph];
All_Cyc_Data = [All_Cyc_Data;CYC_UDDS_kmph;CYC_TU_kmph;CYC_TS_kmph;CYC_TH_kmph];
All_Cyc_Data = [All_Cyc_Data;CYC_TC_kmph;CYC_SC03_kmph;CYC_REP05_kmph;CYC_NYCTRUCK_kmph];
All_Cyc_Data = [All_Cyc_Data;CYC_NYCC_kmph;CYC_NREL2VAIL_kmph;CYC_NEDC_kmph];
All_Cyc_Data = [All_Cyc_Data;CYC_MANHATTAN_kmph;CYC_LA92_kmph;CYC_CATC_kmph;CYC_BUSRTE_kmph;CYC_ARB02_kmph];

len = length(All_Cyc_Data);
All_Cyc_Acc_Data_with_Zero = All_Cyc_Data(2:len,2) - All_Cyc_Data(1:len-1,2);
All_Cyc_Acc_Data_idx = find(All_Cyc_Acc_Data_with_Zero ~= 0);

All_Cyc_Acc_Data = zeros(length(All_Cyc_Acc_Data_idx),1);

for i = 1:length(All_Cyc_Acc_Data_idx)
    All_Cyc_Acc_Data(i) = All_Cyc_Acc_Data_with_Zero(All_Cyc_Acc_Data_idx(i));
end



DrvCycKph_G = All_Cyc_Acc_Data;


title_name = 'ARB02';

figure

valref = fitdist(DrvCycKph_G,'Normal')
histfit(DrvCycKph_G)
i=0;

set(gcf,'Position',[347,162,200,160]);
title(title_name,'FontName','Times New Roman','FontSize',11);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    
% xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
% ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
% legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
% legend(ylabel_msg,'location','NorthEast');