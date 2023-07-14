# Fc_Hybrid_Vehicle_Energy_Management_Strategy
Project achieved in MATLAB/Simulink 2022b, including optimal control algo, prediction algo, DQN training Env. etc.

The project's core dependency >> VehModel/Global&RowData/Config_c230321.m
ALL the .m script, simulink model depending on the data inside the <config_c/data/> initizlizer.

**Installation**
Turn on the terminal and make sure you've located in the right file address;
Clone the repo with the shell command below:
$>> git clone git@github.com:XinhaoTsl/Fc_Hybrid_Vehicle_Energy_Management_Strategy.git

**File definiation**
# 1 VehModel: 
The project is established above the modeling of the Fuel cell hybrid electrical vehicle;
The vehicle's powertrain model is included in this file.
# 2 Markov_Predictor
Consider the vehicle's realtime driving condition as stochastic process, whcih can be describled with the Markov process.
To achieve the realtime optimization, the prediction of the upcoming drving status is necessary；
This project set up a self-update-probability-transfer-matrix (self-learning TPM) mechanism, which is included in this file.
File "SL_Markov_TestBuck.m" is the model-free predictor performance validater, which can be directly run without the operation of the simulink model.
File "Self_learning_Markov.m" is the predictor inside the vehicle simulink model, which is the code dependancy of the real-time-running-ability of the project.
# 3 Rbostg
RBostg is the abbreviation of the name "Rule-Based optimal battery state-of-charge (SOC) trajectory generator"
As you know, it is critical to ensure a "near-optimal battery SOC trajectory" while solving the power allication problem;
The Rbostg is the strategy which can provide the near-optimal SOC trajectory at the beginning of the vehcile driving cycle.
# 4 HESS_control
HESS is the abbreviation of the "hybrid energy storage system"; 
HESS_control means the control strategy of the HESS which responsible for the power allocation among the vehicle's battery and the supercapacitor.

