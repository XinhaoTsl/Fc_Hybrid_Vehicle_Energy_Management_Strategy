load Tcom_3600_CYC_combined_kmph.mat
load Tcom7200_CYC_combined_kmph.mat
Tcom_0(:,:,1) = (1/61)*ones(61,61);


%% Single Picture Plot
figure

view_dimension = 3;
avg = Tcom(:,:,2);

h=bar3(avg);
%axis(0:0.01:1)
for n=1:numel(h)
    cdata=get(h(n),'zdata');
    set(h(n),'cdata',cdata,'facecolor','interp')
end


if view_dimension == 2
    view(2)
elseif view_dimension == 3
    v = [45 30];
    [caz,cel] = view(v);
end

set(gca,'xticklabel',{'3','2','1','0','-1','-2','-3'});
% set(gca,'xticklabel','60','0');
set(gca,'yticklabel',{'3','2','1','0','-1','-2','-3'});
% set(gca, 'YTick',0:10:60);
axis([0 61 0 61])

title_name = 'Empty';
xlabel_msg = 'a_i';
ylabel_msg = 'a_j';
zlabel_msg = 'probability';
    
% Operation frame DO NOT CHANGE
% title(title_name,'FontName','Times New Roman','FontSize',11);

set(gcf,'Position',[347,162,450,450]);
set(gca,'FontName','Times New Roman','FontSize',9,'LineWidth',0.5);
    
xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11);
zlabel(zlabel_msg,'FontName','Times New Roman','FontSize',11);





%% Multiple Picture Plot
% figure
% 
% subplot(1,2,1)
% 
% avg = Tcom_0;
% 
% h=bar3(avg);
% 
% for n=1:numel(h)
%     cdata=get(h(n),'zdata');
%     set(h(n),'cdata',cdata,'facecolor','interp')
% end
% 
% % view(2)
% 
% v = [225 30];
% [caz,cel] = view(v);
% 
% 
% 
% title_name = 'Empty';
% xlabel_msg = 'a_j';
% ylabel_msg = 'a_i';
% zlabel_msg = 'probability';
%     
% 
% set(gca,'FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
%     
% xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
% ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11);
% 
% 
% 
% 
% subplot(1,2,2)
% 
% avg = Tcom_7200_CYC_combined_kmph(:,:,1);
% 
% h=bar3(avg);
% 
% for n=1:numel(h)
%     cdata=get(h(n),'zdata');
%     set(h(n),'cdata',cdata,'facecolor','interp')
% end
% 
% % view(2)
% 
% v = [225 30];
% [caz,cel] = view(v);
% 
% 
% 
% title_name = 'Empty';
% xlabel_msg = 'a_j';
% ylabel_msg = 'a_i';
% zlabel_msg = 'probability';
% 
% 
% set(gcf,'Position',[347,162,800,360]);
% set(gca,'FontName','Times New Roman','FontSize',7,'LineWidth',0.5);
%     
% xlabel(xlabel_msg,'FontName','Times New Roman','FontSize',11);
% ylabel(ylabel_msg,'FontName','Times New Roman','FontSize',11);
