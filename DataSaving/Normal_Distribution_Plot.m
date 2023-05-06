DrvCycKph_G = CYC_ARB02_kmph;
Dck_Start = 2790;


len_G = length(DrvCycKph_G(:,2));


AccSetKph_G = [[1:len_G]',zeros(len_G,1)];
AccSetMph_G = [[1:len_G]',zeros(len_G,1)];


for i=2:len_G
    AccSetKph_G(i,2) = DrvCycKph_G(i,2) - DrvCycKph_G(i-1,2);
end

title_name = 'ARB02';

figure

valref = fitdist(AccSetKph_G(:,2),'Normal');
histfit(AccSetKph_G(:,2));
i=0;

set(gcf,'Position',[347,162,200,160]);
title(title_name,'FontName','Times New Roman','FontSize',11);
set(gca,'FontName','Times New Roman','FontSize',10,'LineWidth',0.5);
    
% xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
% ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11,'LineWidth',1.5);
    
% legend('FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
% legend(ylabel_msg,'location','NorthEast');

