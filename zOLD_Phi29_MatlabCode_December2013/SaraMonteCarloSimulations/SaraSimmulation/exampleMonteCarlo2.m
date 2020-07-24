function exampleMonteCarlo2

% PARAMETERS AND INITIALIZATION
k = 0.5;                      % rate (in "real units", s^-1)
dt = 0.1;                     % simulation dt, make small such that k*dt < 0.2
nTimeSteps = 10000;           % number of dt steps to simulate
r1 = rand(1,nTimeSteps);      % random number for monte carlo
timeStep = nan(1,nTimeSteps); % simulation time steps where steps occur
                              % (pre-allocate r1 and timeStep for speed)

% SIMULATION
s = 0;                        % number of steps taken
t = 1;                        % simulation time points, matlab arrays start at 1
while t < nTimeSteps,
    if r1(t) > 1 - k*dt,
        s = s + 1;            % take a step
        timeStep(s) = t;      % mark the simulation time the step happened
    end
    t = t + 1;                % increase simulation time
end

% EXPONENTIAL DISTRIBUTION
% confirm the delay between steps fits the appropriate exponential distribution
hfig = 1;
figure(hfig); clf;
t1 = 0.25:0.25:10;            % bins for plots and histogram
plot(t1,hist(diff(timeStep*dt),t1)/sum(hist(diff(timeStep*dt),t1))/diff(t1(1:2)),'ok','markersize',4);
hold on;
plot([0 t1], k * exp(-k .* [0 t1]),'-r','linewidth',1.5);
fontSize = 10;
set(gca,'fontsize',fontSize);
set(gca,'linewidth',1);
set(gca,'layer','top');
box off;
set(hfig, 'PaperSize', [3 2.5]);
set(hfig, 'PaperPosition', [0.25 0.25 2.5 2]);
ylabel('probability density, {\it P \prime}')
xlabel('time, {\it t}');
set(gca,'xtick',0:2:10);

% POISSON DISTRIBUTION

% first calculate the distribution of events in the given amount of time
% using a sliding window
timeStepWindow = 100;
nWindows = nTimeSteps - timeStepWindow;
num = zeros(1,nWindows);
for i = 1:nWindows,
    num(i) = length(intersect(i:i+timeStepWindow,timeStep));
end

% plot the distribution and confirm that it fits to the appropriate
% Poisson distribution
hfig = 2;
figure(hfig); clf;
bins = 0:1:15;
bar(bins,hist(num,bins)/sum(hist(num,bins)),'facecolor',[0.4 0.5 0.8]);
hold on;
plot(bins,poisspdf(bins,k*timeStepWindow*dt),'-r','linewidth',1.5);
fontSize = 10;
set(gca,'fontsize',fontSize);
set(gca,'linewidth',1);
set(gca,'layer','top');
box off;
set(hfig, 'PaperSize', [3 2.5]);
set(hfig, 'PaperPosition', [0.25 0.25 2.5 2]);
ylabel('probability, {\it P}')
xlabel('number of events, {\it n}');

% TRAJECTORY
hfig = 3;
figure(hfig); clf;
nEvents = 50;       % show only the first 50 steps
stairs([0 timeStep(1:nEvents)],[0 1:nEvents],'-k','linewidth',1);
fontSize = 10;
set(gca,'fontsize',fontSize);
set(gca,'linewidth',1);
set(gca,'layer','top');
box off;
set(hfig, 'PaperSize', [3 2.5]);
set(hfig, 'PaperPosition', [0.25 0.25 2.5 2]);
xlabel('time, {\it t}');
ylabel('number of events');
