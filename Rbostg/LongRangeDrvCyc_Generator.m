%% xinhaoxu@tesla.com
%  Optimal Soc Traj analysis script

clc
clear

load Driving_cycle_ori_data.mat;
load Driving_cycle_combined_ori_data.mat;
load Driving_cycle_recognition_data.mat;

DrvCycKph = CYC_CSHVR_Vehicle_kmph;
BattSocInit = 0.8;

run GeneralConfig_Calling.m

% plot(0.7*DrvCycKph(:,2))


%% Std Cycle Build

std_UrbanDrvCyc = [CYC_MANHATTAN_kmph(1:540,2)];
std_UrbanDrvCyc_Small = [CYC_MANHATTAN_kmph(1:110,2)];
std_SuburbDrvCyc = [CYC_INDIA_HWY_SAMPLE_kmph(1:50,2);CYC_INDIA_HWY_SAMPLE_kmph(122:622,2);
    CYC_INDIA_HWY_SAMPLE_kmph(861:882,2)];
std_HwDrvCyc = [CYC_US06_HWY_kmph(:,2)];

fprintf('std_UrbanDrvCyc Len: %d, Vave: %2.2f.\n',length(std_UrbanDrvCyc),mean(std_UrbanDrvCyc));
fprintf('std_SuburbDrvCyc Len: %d, Vave: %2.2f.\n',length(std_SuburbDrvCyc),mean(std_SuburbDrvCyc));
fprintf('std_HwDrvCyc Len: %d, Vave: %2.2f.\n',length(std_HwDrvCyc),mean(std_HwDrvCyc));


DrvCycList = struct( ...
    Urban = std_UrbanDrvCyc, ...
    Suburb = std_SuburbDrvCyc, ...
    Highway = std_HwDrvCyc ...
    );


Expected_HwPropList = [0.05:0.05:1];
IntnedCycLen = 7000;


%% Cycle tpye Assignment

for HwTimes = 1:20

    Expected_HwProp = Expected_HwPropList(HwTimes);
    nHw = floor((IntnedCycLen*Expected_HwProp)/length(std_HwDrvCyc));
    nUb = floor((IntnedCycLen - nHw * length(std_HwDrvCyc))/(length(std_UrbanDrvCyc) + ...
        length(std_SuburbDrvCyc)));
    nSb = nUb;

    Assigned_Expected_HwProp = (nHw*length(std_HwDrvCyc))/((nHw*length(std_HwDrvCyc))+ ...
        2*nUb*(length(std_UrbanDrvCyc)+length(std_SuburbDrvCyc)));

    if abs(Assigned_Expected_HwProp - Expected_HwProp) >= 0.02
        nSub = round((IntnedCycLen - nHw*length(std_HwDrvCyc) - nUb*(length(std_UrbanDrvCyc)+ ...
            length(std_SuburbDrvCyc)))/length(std_UrbanDrvCyc_Small));
    else
        nSub = 0;

    end
    
    % GeneratedCyc_Info = [nHw, nUb, nSb, nSub, DrvCycLength
    %                       1    2    3     4        5
    %                      HighwayCyc percentage, SuburbCyc percentage, UrbanCyc percentage]
    %                          6                     7                     8      
    % nHw: Number of Highway Cycle
    % nSb: Number of Suburb Cycle
    % nUb: Number of Urrban Cycle
    % nSub: Number of Small Urban Cycle

    GeneratedCyc_Info(HwTimes,1) = nHw;
    GeneratedCyc_Info(HwTimes,2) = nUb;
    GeneratedCyc_Info(HwTimes,3) = nSb;
    GeneratedCyc_Info(HwTimes,4) = nSub;
    GeneratedCyc_Info(HwTimes,5) = (nHw*length(std_HwDrvCyc)) + ...
        nUb*length(std_UrbanDrvCyc) + nSb*length(std_SuburbDrvCyc) + ...
        nSub*length(std_UrbanDrvCyc_Small);
    GeneratedCyc_Info(HwTimes,6) = (nHw*length(std_HwDrvCyc))/GeneratedCyc_Info(HwTimes,5);
    GeneratedCyc_Info(HwTimes,7) = (nSb*length(std_SuburbDrvCyc))/GeneratedCyc_Info(HwTimes,5);
    GeneratedCyc_Info(HwTimes,8) = 1 - GeneratedCyc_Info(HwTimes,7) - GeneratedCyc_Info(HwTimes,6);
    
    MaxGenCycLen = max(GeneratedCyc_Info(:,5));

end


%% Cycle Generation -- TYPE01 RuleBased

% for HwNum = 1:length(GeneratedCyc_Info(:,5))
%     GeneratedCyc_MsgTemp = [];
%     HwInserted = false;
% 
%     if GeneratedCyc_Info(HwNum,2)
%         for UbTimes = 1:GeneratedCyc_Info(HwNum,2)
%             GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;std_UrbanDrvCyc];
%         end
%     end
% 
%     if GeneratedCyc_Info(HwNum,3)
%         for SbTimes = 1:GeneratedCyc_Info(HwNum,3)
%             GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;std_SuburbDrvCyc];
%             if SbTimes >= ceil(GeneratedCyc_Info(HwNum,3)/2) && GeneratedCyc_Info(HwNum,1) && ~HwInserted
%                 for HwTimes = 1:GeneratedCyc_Info(HwNum,1)
%                     GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;std_HwDrvCyc];
%                 end
%                 HwInserted = true;
%             end
%         end
%     else
%         for HwTimes = 1:GeneratedCyc_Info(HwNum,1)
%             GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;std_HwDrvCyc];
%         end
%     end
% 
%     if GeneratedCyc_Info(HwNum,4)
%         for SubTimes = 1:GeneratedCyc_Info(HwNum,4)
%             GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;std_UrbanDrvCyc_Small];
%         end
%     end
% 
%     GenCycLenComp = MaxGenCycLen - length(GeneratedCyc_MsgTemp);
% 
%     if GenCycLenComp
%         GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;zeros(GenCycLenComp,1)];
%     end
% 
%     GeneratedCyc_Msg(:,HwNum) = GeneratedCyc_MsgTemp;
% 
% end


%% Cycle Generation -- TYPE02 RandomDistribute


for HwNum = 1:length(GeneratedCyc_Info(:,5))

    % Cyc sequential generate
    GeneratedCyc_Distrbt = [];

    if GeneratedCyc_Info(HwNum,2)
        GeneratedCyc_Distrbt(1:GeneratedCyc_Info(HwNum,2),2) = 1;
    end

    if GeneratedCyc_Info(HwNum,3)
        GeneratedCyc_Distrbt(length(GeneratedCyc_Distrbt)+1: ...
            length(GeneratedCyc_Distrbt)+GeneratedCyc_Info(HwNum,3),2) = 2;
    end

    if GeneratedCyc_Info(HwNum,1)
        GeneratedCyc_Distrbt(length(GeneratedCyc_Distrbt)+1: ...
            length(GeneratedCyc_Distrbt)+GeneratedCyc_Info(HwNum,1),2) = 3;
    end

    if GeneratedCyc_Info(HwNum,4)
        GeneratedCyc_Distrbt(length(GeneratedCyc_Distrbt)+1: ...
            length(GeneratedCyc_Distrbt)+GeneratedCyc_Info(HwNum,4),2) = 4;
    end

    % Cyc randomly re-arrange
    GeneratedCyc_Distrbt(3:end,1) = rand(length(GeneratedCyc_Distrbt(3:end,2)),1);
    GeneratedCyc_Distrbt = sortrows(GeneratedCyc_Distrbt,1);

    % Cyc Populate
    GeneratedCyc_MsgTemp = [];
    
    for cycPopu = 1:length(GeneratedCyc_Distrbt(:,2))
        switch GeneratedCyc_Distrbt(cycPopu,2)
            case 1
                rand_gain = (1.3-0.7)*rand(1)+0.7;
                GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;rand_gain*std_UrbanDrvCyc];
            case 2
                rand_gain = (1.3-0.8)*rand(1)+0.8;
                GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;rand_gain*std_SuburbDrvCyc];
            case 3
                rand_gain = (1.1-0.85)*rand(1)+0.85;
                GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;rand_gain*std_HwDrvCyc];
            case 4
                rand_gain = (1.3-0.7)*rand(1)+0.7;
                GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;rand_gain*std_UrbanDrvCyc_Small];
        end
    end
   
    % Cyc smooth
    GeneratedCyc_StepRec = 0;

    for cycPopu = 1:length(GeneratedCyc_Distrbt(:,2))-1

        switch GeneratedCyc_Distrbt(cycPopu,2)
            case 1
                GeneratedCyc_StepRec = GeneratedCyc_StepRec + length(std_UrbanDrvCyc);
            case 2
                GeneratedCyc_StepRec = GeneratedCyc_StepRec + length(std_SuburbDrvCyc);
            case 3
                GeneratedCyc_StepRec = GeneratedCyc_StepRec + length(std_HwDrvCyc);
            case 4
                GeneratedCyc_StepRec = GeneratedCyc_StepRec + length(std_UrbanDrvCyc_Small);
        end
        
        if GeneratedCyc_Distrbt(cycPopu,2) == 3 && ...
            GeneratedCyc_Distrbt(cycPopu+1,2) == 3

            GeneratedCyc_MsgTemp(GeneratedCyc_StepRec-32:GeneratedCyc_StepRec+32) = ...
            GeneratedCyc_MsgTemp(GeneratedCyc_StepRec-32);
        end
        
        if GeneratedCyc_Distrbt(cycPopu,2) == 2 && ...
            GeneratedCyc_Distrbt(cycPopu+1,2) == 2

            GeneratedCyc_MsgTemp(GeneratedCyc_StepRec-32:GeneratedCyc_StepRec+32) = ...
            linspace(GeneratedCyc_MsgTemp(GeneratedCyc_StepRec-32), GeneratedCyc_MsgTemp(GeneratedCyc_StepRec+32),2*32+1);

        end

        if GeneratedCyc_Distrbt(cycPopu,2) == 2 && ...
            GeneratedCyc_Distrbt(cycPopu+1,2) == 3

            GeneratedCyc_MsgTemp(GeneratedCyc_StepRec-32:GeneratedCyc_StepRec+32) = ...
            linspace(GeneratedCyc_MsgTemp(GeneratedCyc_StepRec-32), GeneratedCyc_MsgTemp(GeneratedCyc_StepRec+32),2*32+1);
        end

        if GeneratedCyc_Distrbt(cycPopu,2) == 3 && ...
            GeneratedCyc_Distrbt(cycPopu+1,2) == 2

            GeneratedCyc_MsgTemp(GeneratedCyc_StepRec-32:GeneratedCyc_StepRec+32) = ...
            linspace(GeneratedCyc_MsgTemp(GeneratedCyc_StepRec-32), GeneratedCyc_MsgTemp(GeneratedCyc_StepRec+32),2*32+1);
        end

    end

%     plot(GeneratedCyc_MsgTemp);

    GenCycLenComp = MaxGenCycLen - length(GeneratedCyc_MsgTemp);

    if GenCycLenComp
        GeneratedCyc_MsgTemp = [GeneratedCyc_MsgTemp;zeros(GenCycLenComp,1)];
    end

    GeneratedCyc_Msg(:,HwNum) = GeneratedCyc_MsgTemp;
                

end % The main generator loop END


%% Optimal Soc Drop Analyze

hh = waitbar(0,'Global Processing');

for HwProp = 1:20
    waitbar((HwProp)/20,hh)
    
    CycLen_temp = GeneratedCyc_Info(HwProp,5);
    DrvCycKph = [transpose(1:CycLen_temp),GeneratedCyc_Msg(1:CycLen_temp,HwProp)];
    run DP_forOptSocTrajGenerate_Calling.m;

    C2G_Rec(:,:,HwProp) = C2G;
    Pbatt_opt_Rec(:,:,HwProp) = Pbatt_opt;

    run SocFactorAnalyze_Calling.m;
    
    ThetaTable(HwProp,1) = Expected_HwPropList(HwProp);
    ThetaTable(HwProp,2) = theta(1);
    ThetaTable(HwProp,3) = theta(2);

end
