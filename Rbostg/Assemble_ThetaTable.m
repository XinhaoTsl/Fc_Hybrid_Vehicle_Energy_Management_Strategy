
load theta_OperationResults_Theta1_AssemblyTable.mat
load theta_OperationResults_Theta2_AssemblyTable.mat
load GeneratedCyc_Index.mat


for rowNo = 1:length(Asb_1_ThetaTable(:,1))

    rowTemp_1 = Asb_1_ThetaTable(rowNo,2:end);
    rowTemp_2 = Asb_2_ThetaTable(rowNo,2:end);
    
    if sum(isnan(rowTemp_1))
        rowTemp_1(isnan(rowTemp_1) == 1) = mean(rowTemp_1(isnan(rowTemp_1) == 0));
    end

    Asb_1_ThetaTable(rowNo,2:end) = rowTemp_1;

    if sum(isnan(rowTemp_2))
        rowTemp_2(isnan(rowTemp_2) == 1) = mean(rowTemp_2(isnan(rowTemp_2) == 0));
    end
    
    Asb_2_ThetaTable(rowNo,2:end) = rowTemp_2;

    % theta_OperationResults_mean (tom)
    tom_0122to0125(rowNo,1) = GeneratedCyc_Index(rowNo);
    tom_0122to0125(rowNo,2) = mean(Asb_1_ThetaTable(rowNo,2:end));
    tom_0122to0125(rowNo,3) = mean(Asb_2_ThetaTable(rowNo,2:end));

end

tom_0122to0125 = sortrows(tom_0122to0125,1);

figure
title('theta 1')
xlabel('Hw Prop')
ylabel('theta 1')
plot(tom_0122to0125(2:end,1),tom_0122to0125(2:end,2))

figure
title('theta 2')
xlabel('Hw Prop')
ylabel('theta 2')
plot(tom_0122to0125(2:end,1),tom_0122to0125(2:end,3))