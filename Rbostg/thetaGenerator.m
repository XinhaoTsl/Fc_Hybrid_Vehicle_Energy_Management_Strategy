clc
clear

load bpnn_trained_results.mat
load theta_OperationResults_0119.mat

SolvedHandle = 0.25;

PN_test = mapminmax('apply', SolvedHandle, ps_input);
TN_sim=sim(net, PN_test);
T_sim=mapminmax('reverse', TN_sim, ps_output); 

fprintf('Hw Prop %1.4f has the theta %1.4f', SolvedHandle, T_sim);
