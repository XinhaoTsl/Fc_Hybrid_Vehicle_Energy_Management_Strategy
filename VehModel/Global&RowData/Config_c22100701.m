% Starting configation for 'c221006_FCEV_CDCS';

%% Basic Data loading
clear
clc

load FCEV_original_data.mat
load Driving_cycle_ori_data.mat
load Driving_cycle_recognition_data.mat
load Driving_cycle_combined_ori_data.mat

%% Initialization
Driving_cycle_v_kmph = CYC_NEDC_kmph;
Driving_cycle_a_mps2 = CYC_NEDC_a_mps2;

% Driving_cycle_v_kmph=CYC_combined_kmph;%%%%%%%%%%%%%%%%%%%%%%%%%%修改具体工况
% Driving_cycle_a_mps2=CYC_combined_a_mps2;%%%%%%%%%%%%%%%%%%%%%%%%%修改具体工况

usd2rmb = 7.116;
Bat_SOC_ini=0.3;
%Time_sample=60;
%Time_update=90;
SOC_ave_city=0.01934;%城市工况(MANHATTAN,BUSRTE,NYCC)SOC/S(单位里程消耗SOC值, 单位:km-1)
SOC_ave_suburb=0.01394;%郊区工况(IM240,SC03,INDIA_HWY)SOC/S(单位里程消耗SOC值, 单位:km-1)
SOC_ave_highway=0.01575;%高速路工况(US06_HWY,REP05,HWFET)SOC/S(单位里程消耗SOC值, 单位:km-1)


%% DP Test zoom

%% Data configration          
ts = 1;                               %time step
N = length(Driving_cycle_v_kmph);     %length of time vector
t = Driving_cycle_v_kmph(:,1);
v = Driving_cycle_v_kmph(:,2);
sim("VehDymcModel_Outputer");
P_dem = PwrReqIni_W(:,1);

subplot(2,1,1);
plot(t,P_dem)                       
title('Power demand')
subplot(2,1,2);
plot(t,v)
title('Desired velocity')

% Weighting factor
w_a = 1;
w_b = 1;

fc_pwr_map=[0 2 5	7.5	10	20	30	40	50].*1000;                           % kW (net) including parasitic losses
fc_eff_map=[10 33 49.2	53.3	55.9	59.6	59.1	56.2	50.8]/100;  % efficiency indexed by fc_pwr
fc_fuel_lhv=120.0./1000;                                                     % (J/g), lower heating value of the fuel

SOC_min = 0.2;         % Lower SOC limit
SOC_max = 0.8;         % Upper SOC limit
SOC_tag = 0.3;         % Target SOC Value

Pf_max = 30;        % [W] Maximum fuel cell power // Pe_max
Pb_max = 50000;        % [W] Maximum battery power
Q_batt = 20.7*3600;    % [As] Battery capacity
U_oc = 320;            % [V] Open ciruit voltage of the battery
SOC_grid = linspace(SOC_min,SOC_max,80)';   %SOC grid
ns = length(SOC_grid);

%% DP
V = zeros(ns,N);            %Value function
V(:,N) = 0;                 %Boundary condition   
for i = N-1:-1:1            %Iterate through time vector
    for j = 1:ns            %Iterate through SOC grid
     
     % 充电的最大功率   
     lb = max([(((SOC_max-SOC_grid(j))*Q_batt*U_oc)/-ts),-Pb_max]);          %lower bound P_batt
     
     %放电的最大功率
     ub = min([(((SOC_min-SOC_grid(j))*Q_batt*U_oc)/-ts),Pb_max, P_dem(i)]);                 %Upper bound P_batt
     
     P_batt_grid = linspace(lb,ub,250);      %P_batt grid 
     P_fc = P_dem(i) - P_batt_grid;         %P_eng at for P_batt_grid
     fc_m = (P_fc./(interp1(fc_pwr_map,fc_eff_map,P_fc).*fc_fuel_lhv));
     SOC_next = SOC_grid(j) - (ts .* P_batt_grid ./ (Q_batt*U_oc));

     c2g = w_a.*(SOC_next-SOC_tag).^2 + w_b.*(fc_m); %costtogo Cost Function (interp1(1:9,FC_ori_fuel_rate_gps,5))

     
     V_nxt = interp1(SOC_grid,V(:,i+1),SOC_next);
     [V(j,i), k] = min([c2g + V_nxt]);
     u_opt(j,i) = P_batt_grid(k); 
    end
end



[Pb_07, Pe_07, FC_07, SOC_07]= RUN_HEV(0.7,N,SOC_grid,u_opt,P_dem);
[Pb_05, Pe_05, FC_05, SOC_05]= RUN_HEV(0.5,N,SOC_grid,u_opt,P_dem);
[Pb_03, Pe_03, FC_03, SOC_03]= RUN_HEV(0.3,N,SOC_grid,u_opt,P_dem);
figure;
plot(SOC_07)
hold on;
plot(SOC_05)
plot(SOC_03)
title('SOC')
legend('SOC 0.7','SOC 0.5','SOC 0.3')


%% 计算行驶里程(km) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Trip_distance_total_km=sum(Driving_cycle_v_kmph(:,2)/3.6)/1000;%总行驶里程


%% 加载行驶工况识别模块
l=size(Driving_cycle_v_kmph,1);%样本数量（时间长度）
m=Time_sample;%采样周期
n=Time_update;%更新周期

p=floor((l-m)/n);%识别周期的个数, 后面不足n的忽略，无需再识别
%s=p+2;%整个行驶工况的分段数量, 第一段为[1, Ts]，该段没有数据采集, 工况为0，第二段为[Ts+1, Ts+pn],正常采集和更新，
%第三段为[Ts+pn+1，l],此段不能正常进行数据采集, 与上一更新周期识别结果一致

Data_C1=zeros(1,15);%存储第一段特征参数数据
Data_C2=zeros(p,15);%15个特征参数,存储第二段特征参数数据
Data_C3=zeros(1,15);%存储第三段特征参数数据
%Data_F=zeros(?,3);%主成分分析后数据，3个主成分
%Data_C2L=zeros(p*n,15);

for i=1:p
    V=Driving_cycle_v_kmph(n*(i-1)+1:n*(i-1)+m,2);%1s-120s,61s-180s,...的行驶工况数据（举例说明）%%%%%%%%%%%%修改具体工况
    A=Driving_cycle_a_mps2(n*(i-1)+1:n*(i-1)+m,2);%1s-120s,61as-180s,...的加速度数据（举例说明）%%%%%%%%%%%修改具体工况
    VA=[V,A];
    C1=Fun_C1_v_g_ave(V);%平均车速
    C2=Fun_C2_v_g_max(V);%最大车速
    C3=Fun_C3_a_g_max(A);%最大加速度
    C4=Fun_C4_a_g_ave(A);%平均加速度
    C5=Fun_C5_d_g_max(A);%最大减速度
    C6=Fun_C6_d_g_ave(A);%平均减速度
    C7=Fun_C7_P_a(A);%加速比例
    C8=Fun_C8_P_d(A);%减速比例
    C9=Fun_C9_P_c(VA);%恒速比例
    C10=1-C7-C8-C9;%怠速比例
    C11=Fun_C11_T_i(V);%怠速次数
    C12=Fun_C12_S(V);%行驶距离
    C13=Fun_C13_SDv(V);%速度标准差
    C14=Fun_C14_SDa(A);%加速度标准差
    C15=Fun_C15_SDd(A);%减速度标准差
    Data_C2(i,1:15)=[C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15];%单位：采样周长
    Data_C2L(n*(i-1)+m+1:n*i+m,:)=repmat(Data_C2(i,1:15),n,1);%周期长度扩展为以秒为长度
end

Data_C1L=zeros(m,15);
Data_C2L(1:m,:)=Data_C1L;
Data_C3=Data_C2(end,:);
Data_C3L=repmat(Data_C3,l-n*p-m,1);
Data_C123L=[Data_C2L;Data_C3L];

Data_time=1:l;%时间序列
Data_time=Data_time';

%Data按特征参数拆分
Data_C1=[Data_time Data_C123L(:,1)];
Data_C2=[Data_time Data_C123L(:,2)];
Data_C3=[Data_time Data_C123L(:,3)];
Data_C4=[Data_time Data_C123L(:,4)];
Data_C5=[Data_time Data_C123L(:,5)];
Data_C6=[Data_time Data_C123L(:,6)];
Data_C7=[Data_time Data_C123L(:,7)];
Data_C8=[Data_time Data_C123L(:,8)];
Data_C9=[Data_time Data_C123L(:,9)];
Data_C10=[Data_time Data_C123L(:,10)];
Data_C11=[Data_time Data_C123L(:,11)];
Data_C12=[Data_time Data_C123L(:,12)];
Data_C13=[Data_time Data_C123L(:,13)];
Data_C14=[Data_time Data_C123L(:,14)];
Data_C15=[Data_time Data_C123L(:,15)];

%主成分分析处理
Data_F=Data_C123L*PV;%PV为主成分得分系数矩阵
Data_F1=[Data_time Data_F(:,1)];%主成分F1
Data_F2=[Data_time Data_F(:,2)];%主成分F2
Data_F3=[Data_time Data_F(:,3)];%主成分F3


%% 基于交通信息的纯电行驶里程估算 (基础：黎金科-吉林大学-插电式混合动力汽车出行工况预测及自适应控制策略研究) %%%%%%%%%%%
%较为粗糙，需要整理
%    STEP1    整个行程的交通流量信息(200m为一个路段)
q=0.2;%每个路段的长度(km)
l1=size(Driving_cycle_v_kmph,1);%样本数量（时间长度）
sumS=0;
for k=1:l1%每一时刻
    sumS=sumS+Driving_cycle_v_kmph(k,2)/3600;%j时刻时已行驶距离(km)
    S_travelled_km(k)=sumS;
end
[S_travelled_km_process,index_1,index_2]=unique(S_travelled_km);%去重复数据
%index_1返回去除重复后的元素在原来数组中的位置，
%index_2返回原来数组中的元素在去除重复后数组中的位置；
l2=length(S_travelled_km_process);
l3=ceil(Trip_distance_total_km/q);%路段数量
for z=1:l3-1
    index_3(z)=round(interp1(S_travelled_km_process,1:l2,q*z));%求每个分段所处的时间
end
index_4=[index_1(index_3);l1];%分段在原时域坐标下的位置(共分成322段)
for y=2:length(index_4)
    index_5_1(y)=index_4(y-1)+1;
    index_5_2(y)=index_4(y);
end
index_5=[1,index_5_1(2:length(index_4));index_4(1),index_5_2(2:length(index_4))]';%每一段的时间起止时刻
for x=1:l3-1
    Driving_cycle_traffic_speed_kmph(x)=mean(Driving_cycle_v_kmph(index_5(x,1):index_5(x,2),2));
    S(x,:)=q*(x-1):q:q*x;%周期长度扩展为以秒为长度
end
Driving_cycle_traffic_speed_kmph=[Driving_cycle_traffic_speed_kmph';mean(Driving_cycle_v_kmph(index_5(end,1):index_5(end,2),2))];
S_end=[S(end,2),Trip_distance_total_km];
S=[S;S_end];
S_V=[S,Driving_cycle_traffic_speed_kmph];
%stairs(S_V(:,1),S_V(:,3));%参照图5.12
%figure (1);%画图1开始%%%%%%%%%%%%%%%%%%%%%%
%for x=2:size(S_V,1)
    %plot([S_V(x,1),S_V(x,1)],[S_V(x-1,3),S_V(x,3)]);
    %hold on;
    %plot([S_V(x,1),S_V(x,2)],[S_V(x,3),S_V(x,3)]);
    %hold on;
%end
%plot([S_V(1,1),S_V(1,2)],[S_V(1,3),S_V(1,3)]);
%xlabel('行驶里程 (km)');
%ylabel('车流速度 (km/h)');
%title('基于智能交通系统的车流速度(模拟)---行驶距离-车流速度图像');%画图1结束%%%%%
%    STEP2    将''路程-车流速度''图像转换成''时间-车流速度''图像
T=3600*(S_V(:,2)-S_V(:,1))./S_V(:,3);%每段路程需要时间
T_V_1(1)=T(1);
for x=2:l3
    T_V_1(x)=T_V_1(x-1)+T(x);%每一段终止时刻
    T_V_2(x)=T_V_1(x)-T(x);%每一段开始时刻
end
T_V_2(1)=0;
T_V=[T_V_2',T_V_1',S_V(:,3)];
%figure (2);%画图2开始%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for x=2:size(T_V,1)
    %plot([T_V(x,1),T_V(x,1)],[S_V(x-1,3),S_V(x,3)]);
    %hold on;
    %plot([T_V(x,1),T_V(x,2)],[S_V(x,3),S_V(x,3)]);
    %hold on;
%end
%plot([T_V(1,1),T_V(1,2)],[S_V(1,3),S_V(1,3)]);
%xlabel('时间 (s)');
%ylabel('车流速度 (km/h)');
%title('基于智能交通系统的车流速度(模拟)---时间-车流速度图像');%画图2结束%%%%%%%%%%%%%%%%%%%%%%
%    STEP3    将''时间-车流速度''图像做平滑处理
T_V_process_1=(T_V(:,1)+T_V(:,2))/2;%时间轴
T_V_process_2=T_V(:,3);%平均车速轴
%plot(T_V_process(:,1),T_V_process(:,2));
for x=1:floor(T_V(end,2))
    T_V_process(x)=interp1([0;T_V_process_1;ceil(T_V(end,2))],[0;T_V_process_2;0],x,'cubic');%用于工况识别的速度曲线
end
for x=2:length(T_V_process)
    T_A_process(x)=T_V_process(x)-T_V_process(x-1);%用于工况识别的加速度曲线
end
%    STEP4    行驶工况识别 (获取''行驶里程---行驶工况''曲线)
p1=floor((length(T_V_process)-m)/n);%识别周期的个数, 后面不足n的忽略，无需再识别
%s=p+2;%整个行驶工况的分段数量, 第一段为[1, Ts]，该段没有数据采集, 工况为0，第二段为[Ts+1, Ts+pn],正常采集和更新，
%第三段为[Ts+pn+1，l],此段不能正常进行数据采集, 与上一更新周期识别结果一致
Data_C11=zeros(1,15);%存储第一段特征参数数据
Data_C21=zeros(p1,15);%15个特征参数,存储第二段特征参数数据
Data_C31=zeros(1,15);%存储第三段特征参数数据
%Data_F=zeros(?,3);%主成分分析后数据，3个主成分
%Data_C2L=zeros(p*n,15);
for i=1:p1
    V1=T_V_process(n*(i-1)+1:n*(i-1)+m);%1s-120s,61s-180s,...的行驶工况数据（举例说明）%%%%%%%%%%%%修改具体工况
    A1=T_A_process(n*(i-1)+1:n*(i-1)+m);%1s-120s,61as-180s,...的加速度数据（举例说明）%%%%%%%%%%%修改具体工况
    VA1=[V1,A1];
    C11=Fun_C1_v_g_ave(V1);%平均车速
    C21=Fun_C2_v_g_max(V1);%最大车速
    C31=Fun_C3_a_g_max(A1);%最大加速度
    C41=Fun_C4_a_g_ave(A1);%平均加速度
    C51=Fun_C5_d_g_max(A1);%最大减速度
    C61=Fun_C6_d_g_ave(A1);%平均减速度
    C71=Fun_C7_P_a(A1);%加速比例
    C81=Fun_C8_P_d(A1);%减速比例
    C91=Fun_C9_P_c(VA1);%恒速比例
    C101=1-C11-C81-C91;%怠速比例
    C111=Fun_C11_T_i(V1);%怠速次数
    C121=Fun_C12_S(V1);%行驶距离
    C131=Fun_C13_SDv(V1);%速度标准差
    C141=Fun_C14_SDa(A1);%加速度标准差
    C151=Fun_C15_SDd(A1);%减速度标准差
    Data_C21(i,1:15)=[C11 C21 C31 C41 C51 C61 C71 C81 C91 C101 C111 C121 C131 C141 C151];%单位：采样周长
    Data_C2L1(n*(i-1)+m+1:n*i+m,:)=repmat(Data_C21(i,1:15),n,1);%周期长度扩展为以秒为长度
end
Data_C1L1=zeros(m,15);
Data_C2L1(1:m,:)=Data_C1L1;
Data_C31=Data_C21(end,:);
Data_C3L1=repmat(Data_C31,length(T_V_process)-n*p1-m,1);
Data_C123L1=[Data_C2L1;Data_C3L1];
%主成分分析处理
Data_F11=Data_C123L1*PV;%PV为主成分得分系数矩阵
%工况识别
Driving_cycle_type_temp=net([Data_F11]');%输出为二进制数[1;0;0]、[0;1;0]或[0;0;1]
[A,index_6]=max(Driving_cycle_type_temp);%A为最大值, index为最大值索引, 该索引值即为工况类型
DC=index_6;%行驶工况类型
S_DC_1(1)=0;
for x=2:length(T_V_process)
    S_DC_1(x)=S_DC_1(x-1)+T_V_process(x)/(3.6*1000);%行驶距离轴
    S_DC_2(x)=DC(x);
end
S_DC_2(1)=S_DC_2(2);
S_DC_process=[S_DC_1;S_DC_2]';%第一列为行驶距离，第二列为工况类型
%    STEP5    纯电行驶里程估算（求未行驶里程需要消耗的SOC值）
S_DC_process_2=S_DC_2;
S_DC_process_2(S_DC_process_2==1)=SOC_ave_city;
S_DC_process_2(S_DC_process_2==2)=SOC_ave_suburb;
S_DC_process_2(S_DC_process_2==3)=SOC_ave_highway;
S_DC_process_2=[S_DC_process(:,1),S_DC_process_2'];%%第一列为行驶距离，第二列为各工况类型的每公里消耗SOC值
l4=floor(S_DC_process_2(end,1)/0.1);
for x=1:l4
    S_DC_process_3_1(x)=0.1*x;
    S_DC_process_3_2(x)=interp1(S_DC_process_2(:,1),S_DC_process_2(:,2),0.1*x);
end
SOC_total=sum(S_DC_process_3_2)*0.1;%整个工况预计消耗SOC值(纯电模式)
S_DC_process_3=[0,S_DC_process_3_1;S_DC_process_3_2(1),S_DC_process_3_2]';%离散化后的数据(间隔0.1km)
for x=1:size(S_DC_process_3)
    Sr_SOC(x)=SOC_total-0.1*sum(S_DC_process_3(1:x,2));
end
Sr_SOC=[SOC_total,Sr_SOC(1:end-1)];%剩余行驶里程所需SOC
Sr=S_DC_process_3(end,1)-S_DC_process_3(:,1);
Sr_SOC_process=[Sr,Sr_SOC'];%第一列为剩余行驶里程，第二列为剩余行驶里程所需SOC
SOCr_e=0:0.005:0.6;%可用SOC([0.3 0.9]-0.3)
S_r=floor(max(Sr_SOC_process(:,1))):-1:0;%剩余行驶里程
for i=1:length(SOCr_e)
    for x=1:length(S_r)%剩余行驶里程
        SOC_r(x)=interp1(Sr_SOC_process(:,1),Sr_SOC_process(:,2),S_r(x));%剩余行驶里程所需SOC
        if SOC_r(x)-SOCr_e(i)>=0
            Sr_e(i,x)=S_r(x)-interp1(Sr_SOC_process(:,2),Sr_SOC_process(:,1),SOC_r(x)-SOCr_e(i));%剩余纯电行驶里程
        else Sr_e(i,x)=S_r(x);
        end
    end
end
%surf(S_r,SOCr_e,Sr_e);
%xlabel('剩余行驶里程 (km)');
%ylabel('可用SOC');
%zlabel('剩余纯电行驶里程 (km)');


%% 电池组电压平均值
Bat_U_avg_V=Bat_num_se*mean(Bat_ori_Uoc_V);%电池电压设为固定值, 取为电池开路电压的平均值
%用于电流的估算


%% 在使用模糊控制器时首先读取fis文件
%MYFLC=readfis('Fuzzy_controller');
%gensurf(MYFLC);%生成控制规则曲面图