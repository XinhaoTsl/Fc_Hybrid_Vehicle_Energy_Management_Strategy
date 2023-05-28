
aa = linspace(0,120,300);
bb = linspace(120,120,6400);
cc = linspace(120,0,300);

generated_PureHwCyc_temp = [aa,bb,cc];

CycTurbulence = randi([-2,2],1,length(generated_PureHwCyc_temp));
timeline = [1:length(generated_PureHwCyc_temp)]';
generated_PureHwCyc = [timeline, transpose(generated_PureHwCyc_temp)];


% plot(generated_PureHwCyc(:,2));