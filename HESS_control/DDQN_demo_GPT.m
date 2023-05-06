% Define the environment
env = rlPredefinedEnv("CartPole-Discrete");

% Create the DQN and target networks
numInputs = numel(env.ObservationInfo);
numActions = numel(env.ActionInfo);
layers = [
    imageInputLayer([numInputs 1 1],"Normalization","none","Name","observation")
    fullyConnectedLayer(24,"Name","fc1")
    reluLayer("Name","relu1")
    fullyConnectedLayer(24,"Name","fc2")
    reluLayer("Name","relu2")
    fullyConnectedLayer(numActions,"Name","output")];

dqn = rlDQNAgent(layers,env.ActionInfo);

% Create the target network with the same architecture
targetDqn = dqn;
targetDqn.QNetwork = dqn.QNetwork;

% Define the training options
maxEpisodes = 1000;
maxSteps = 500;
gamma = 0.99;
epsilon = 0.1;
miniBatchSize = 64;
learnRate = 0.001;

opt = rlDQNAgentOptions;
opt.EpsilonGreedyExploration.Epsilon = epsilon;
opt.TargetUpdateFrequency = 100;
opt.ExperienceBufferLength = 10000;
opt.DiscountFactor = gamma;
opt.MiniBatchSize = miniBatchSize;
opt.LearnRate = learnRate;

% Create the Double DQN agent
ddqn = rlDoubleDQNAgent(dqn,targetDqn,opt);

% Train the Double DQN agent
trainOpts = rlTrainingOptions;
trainOpts.MaxEpisodes = maxEpisodes;
trainOpts.MaxStepsPerEpisode = maxSteps;
trainOpts.StopTrainingCriteria = "AverageReward";
trainOpts.StopTrainingValue = 195;
trainOpts.ScoreAveragingWindowLength = 50;

trainingStats = train(ddqn,env,trainOpts);

% Test the Double DQN agent
simOpts = rlSimulationOptions("MaxSteps",maxSteps);
experience = sim(dqn,env,simOpts);
