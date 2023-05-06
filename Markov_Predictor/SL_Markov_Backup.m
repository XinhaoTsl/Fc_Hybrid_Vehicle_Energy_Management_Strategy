%% Powered by Xinhaoxu@tesla
clc
clear

load Driving_cycle_ori_data.mat;
load Driving_cycle_combined_ori_data.mat;
load Driving_cycle_recognition_data.mat;

%% Replace The Cycle For Distribution Analyze
DrvCycKph = CYC_LA92_kmph;

%% Operation Path
Temp_DrvCycVph = [zeros(9,1);DrvCycKph(:,2)/3.6];
Test_DrvCycVps = [[0:length(Temp_DrvCycVph)-1]',Temp_DrvCycVph];

%% Rowing update
for step = 1:length(DrvCycKph)
    for i=1:10
        v_hstTemp(i) = Temp_DrvCycVph(step+10-i);
        % v_hstTemp = [,u(2),u(3),u(4),u(5),u(6),u(7),u(8),u(9),u(10)];
    end

%% Test Block
PredLen = 5;    % Prediction Length
alpha = 0.1;    % Learning Rate
%v_hstTemp = [u(1),u(2),u(3),u(4),u(5),u(6),u(7),u(8),u(9),u(10)];   % Latest

% persistent count v_hst a_hst Tcom Tflag;
% 
% persistent Fre_ij1 Fre_ij0 fre_ij1;
% % Fre_ij1 = [Fre1ij1 Fre2ij1 Fre3ij1 Fre4ij1 Fre5ij1 Fre6ij1 Fre7ij1 Fre8ij1 Fre9ij1]; % Fre^l_ij(L)
% % Fre_ij0 = [Fre1ij0 Fre2ij0 Fre3ij0 Fre4ij0 Fre5ij0 Fre6ij0 Fre7ij0 Fre8ij0 Fre9ij0]; % Fre^l_ij(L-1)
% % fre_ij1 = [fre1ij1 fre2ij1 fre3ij1 fre4ij1 fre5ij1 fre6ij1 fre7ij1 fre8ij1 fre9ij1]; % fre^l_ij(L)
% 
% persistent Fre_oi1 Fre_oi0 fre_oi1;
% % Fre_oi1 = [Fre1oi1 Fre2oi1 Fre3oi1 Fre4oi1 Fre5oi1 Fre6oi1 Fre7oi1 Fre8oi1 Fre9oi1]; % Fre^l_oi(L)
% % Fre_oi0 = [Fre1oi0 Fre2oi0 Fre3oi0 Fre4oi0 Fre5oi0 Fre6oi0 Fre7oi0 Fre8oi0 Fre9oi0]; % Fre^l_oi(L-1)
% % fre_oi1 = [fre1oi1 fre2oi1 fre3oi1 fre4oi1 fre5oi1 fre6oi1 fre7oi1 fre8oi1 fre9oi1]; % fre^l_oi(L)

ailookup = 3:-0.1:-3;
ajlookup = -3:0.1:3;

if step==0

elseif step==1    % FirstRound For Initialization
    count = 1;
    a_hst = zeros(1,10); a_hst(1) = v_hstTemp(1);   % a_hst = [a_current a_1 a_2 ... a_9];
    v_hst = zeros(1,10); v_hst(1) = v_hstTemp(1);   % v_hst = [v_current v_1 v_2 ... v_9];
    
    for i=1:9
        Tcom(:,:,i) = 1/61 * ones(61,61);  % (a_i,a_j,l) Tcom = [T_1 T_2 T_3 T_4 T_5 T_6 T_7 T_8 T_9];
        Tflag(:,:,i) = zeros(61,61); % Identify which element havent been updated yet 1-Y/0-N;
    end
        
    Fre_ij1 = zeros(1,9); Fre_ij0 = zeros(1,9); fre_ij1 = zeros(1,9);
    Fre_oi1 = zeros(1,9); Fre_oi0 = zeros(1,9); fre_oi1 = zeros(1,9);

    a_j = round(a_hst(1),1);

    for i=1:PredLen   % l loop
        if (abs(a_j-0) < 1e-4) % if a_j == 0;

            % Elements Calculation
            Fre_ij0(i) = 8/8;       % l 1:9
            fre_ij1(i) = 1;         % l 1:9
            Fre_ij1(i) = Fre_ij0(i)+alpha*(fre_ij1(i)-Fre_ij0(i));

            Fre_oi0(i) = 8/8;
            fre_oi1(i) = 1;
            Fre_oi1(i) = Fre_oi0(i)+alpha*(fre_oi1(i)-Fre_oi0(i));

            % Row Update
            Tcom(31,31,i) = Fre_ij1(i)/ Fre_oi1(i); % l also desiding  which Tpm to updated
            Tflag(31,31,i) = 1; % flag

            for ii=find(abs(Tcom(31,:,i)-Tcom(31,31,i))>1e-4)
                Tcom(31,ii,i) = 0; end

        else    % if a_j != 0;

            % Elements Calculation
            Fre_ij0(i) = 0;       % l 1:9
            fre_ij1(i) = 1;       % l 1:9
            Fre_ij1(i) = Fre_ij0(i)+alpha*(fre_ij1(i)-Fre_ij0(i));

            Fre_oi0(i) = 8/8;
            fre_oi1(i) = 1;
            Fre_oi1(i) = Fre_oi0(i)+alpha*(fre_oi1(i)-Fre_oi0(i));

            % Row Update
            Tcom(31,find(abs(ajlookup-(a_j))<1e-4),i) = Fre_ij1(i)/ Fre_oi1(i);
            Tflag(31,find(abs(ajlookup-(a_j))<1e-4),i) = 1;

            for ii=find(abs(Tcom(31,:,i)-(Fre_ij1(i)/ Fre_oi1(i)))>1e-4)
                Tcom(31,ii,i) = (1-Fre_ij1(i)/ Fre_oi1(i))/60; 
            end
        end   
    end

else    % Normal Update Process
    
    count = count + 1;  % WatchDog
    a_hst = round(v_hstTemp-v_hst,1);
    v_hst = v_hstTemp;

    a_j = round(a_hst(1),1);    % flag
    a_oi = round(a_hst(2),1);   % flag
    a1_ij = a_j - a_oi;         % flag
    
    for i=1:PredLen % Prediction Length

        % flag^l_ij(L) Calculation
        a_i = round(a_hst(i+1),1);  % The floating a_i
        a_ij = round(a_hst(i),1);   % The floating a_j
        ai_ij = a_ij - a_i;

        if (abs(a_oi - a_i) < 1e-4)
            fre_oi1(i) = 1;

            if (abs(ai_ij - a1_ij) < 1e-4)
                fre_ij1(i) = 1;
            else
                fre_ij1(i) = 0;
            end

        else
            fre_ij1(i) = 0;
            fre_oi1(i) = 0; 
        end

        % Fre^l_ij(L) Update
        Fre_ij1(i) = Fre_ij1(i) + alpha*(fre_ij1(i) - Fre_ij1(i));

        % Fre^l_oi(L) Update
        Fre_oi1(i) = Fre_oi1(i) + alpha*(fre_oi1(i) - Fre_oi1(i));
        
        % TPM update
        ri = find(abs(ailookup-(a_i))<1e-4);
        cj = find(abs(ajlookup-(a_j))<1e-4);
        Tcom(ri,cj,i) = Fre_ij1(i)/ Fre_oi1(i);
        Tflag(ri,cj,i) = 1;

        nonZeroSum = 0;
        for ii=find(Tflag(ri,:,i)==1)
            nonZeroSum = nonZeroSum + Tcom(ri,ii,i); end

        for iii = 1:61
            if Tflag(ri,iii,i) == 0
                Tcom(ri,iii,i) = 0;
            else
                Tcom(ri,iii,i) = Tcom(ri,iii,i)./nonZeroSum;
            end

        %for ii=find(Tflag(ri,:,i)==0)
            %Tcom(ri,ii,i) = (1-nonZeroSum)/length(find(Tflag(ri,:,i)==0));
            %Tcom(ri,ii,i) = 0;
        end

        % Predictive Acc Step Pa_j Abbreviated as aj

        paj_table(i) = sum(Tcom((find(abs(ailookup-a_j) < 1e-4)),:,i)*ajlookup');
        pvj_table(i) = v_hst(1) + sum(paj_table(1,1:i));
    end
    plot((step+1:step+i),pvj_table(1:i))
    hold on
    aaa=1;
end

%% Test Block End
end

plot(1:step,DrvCycKph(:,2)./3.6,'b',LineWidth=2)
hold off