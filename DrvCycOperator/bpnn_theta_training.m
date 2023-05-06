clc
clear
load theta_OperationResults_0123_02.mat


%%（1）训练测试数据（特征数R*样本数Q）
P_train = transpose(ThetaTable(:,2)); %R*Q
[PN_train,ps_input] = mapminmax(P_train,-1,1); %训练输入归一化

T_train = transpose(ThetaTable(:,3)); %S*Q
[TN_train,ps_output] = mapminmax(T_train,-1,1);

P_test = transpose(ThetaTable(:,2));
PN_test = mapminmax('apply',P_test,ps_input); %测试输入归一化
T_test = transpose(ThetaTable(:,3));    

%%（2）构建网络并设置训练参数
%net=newff(PR,[S1,S2,...],{TF1,TF2,...},BTF,BLF,PF); %输入样本范围(R,2)；隐层、输出层神经元数；激活（传输）函数；网络训练函数（traingdx）；网络学习函数（learngdm）；性能函数（mse）
%1）TF：tansig(logsig),purelin,poslin(ReLU)；2）BTF：trainlm（中等网络函数逼近/存储空间大），traingdx、traingda（某些问题有效/速度慢），trainscg（大型网络通用），trainrp（模式识别），trainbr（贝叶斯归一化法提高泛化能力）
net=newff(minmax(PN_train),[5,1],{'tansig','purelin'},'traingdx');
net.trainParam.show=50; %显示训练过程
net.trainParam.lr=0.05; %学习率
net.trainParam.epochs=300; %最大迭代次数
net.trainParam.goal=1.0e-5; %性能目标

%%（3）网络训练
%[net,tr,Y,E,Pf,Af]=train(net,P,T,Pi,Ai,VV,TV); %1）网络，训练记录（epoch,perf），网络输出，网络误差，最终输入延迟，最终层延迟；2）网络，输入，期望，初始输入延迟，初始层延迟，确认样本结构（[]），测试样本结构（[]）
[net,tr]=train(net,PN_train,TN_train);
%save 'E:\Matlab Codes\netName' net; %保存网络

%%（4）训练结果：T=TF2(W2*TF1(W1*P+B1)+B2)
W1=net.IW{1,1}; %输入层到隐层权值
B1=net.b{1,1}; %隐层神经元偏置（阈值）
W2=net.LW{2,1}; %隐层到输出层权值
B2=net.b{2,1}; %输出层神经元偏置

%%（5）网络仿真预测
%[Y,Pf,Af,E,perf]=sim(net,P,Pi,Ai,T); %1）网络拟合/预测值，最终输入延迟，最终层延迟，网络误差，网络性能；2）网络，预测输入，初始输入延迟，初始层延迟，预测期望
%load 'E:\Matlab Codes\netName' net; %加载网络
TN_sim=sim(net,PN_test);
T_sim=mapminmax('reverse',TN_sim,ps_output); %测试结果反归一化

%%（6）结果展示
plotperform(tr); %训练性能
testNumber=length(T_test);
plot(1:testNumber,T_sim,'ro',1:testNumber,T_test,'b-');




% %% 构造神经网络
% net = newff(xn,yn,[4,1],{'tansig','logsig'},'traingd'); %隐层神经元个数为4
% %设置训练次数
% net.trainParam.epochs = 10000; %隐层神经元个数为4
% %训练网络所要达到的目标误差
% net.trainParam.goal = 0.65 * 10^(-3);
% % 设置学习率
% net.trainParam.lr=0.1;
% %网络误差如果连续6次迭代都没变化，则matlab会默认终止训练。为了让程序继续运行，用以下命令取消这条设置
% net.divideFcn = '';
% 
% 
% %% 对训练集进行训练
% net=train(net1,xn,yn); %隐层神经元个数为4
% 
% 
% %% 预测训练集
% predicy=sim(net,xn); %隐层神经元个数为4
% %将得到的数据反归一化得到预测数据
% predict_=mapminmax('reverse', predicy, outputStr); %隐层神经元个数为4
% 
% 
% %% 对训练集预测及原始结果进行绘图
% plot(y,'b')
% hold on
% plot(predict_,'r')

