L = length(SC_SocTable);
Temp_SC_SocTable = SC_SocTable;
SC_SocTable(1:L,1) = Temp_SC_SocTable(L:-1:1,1);
SC_SocTable(1:L,2) = Temp_SC_SocTable(L:-1:1,2);

% 
% for i=1:length(SC_SocTable(:,1))
%     SC_SocTable(i,1) = Temp_SC_SocTable()

