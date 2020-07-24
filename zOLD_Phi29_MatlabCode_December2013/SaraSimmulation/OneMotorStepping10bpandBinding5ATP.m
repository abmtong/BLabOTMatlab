function exampleMonteCarlo2

% PARAMETERS AND INITIALIZATION
k = 10;                      % rate (in "real units", s^-1)      %??? why this rate (supposedly the rate of the step is once every 0.5 seconds)
dt = 0.04;                    % simulation dt, make small such that k*dt < 0.2      % why this dt? (you want to sample once every 0.1 seconds if it gave one step)
nTimeSteps = 10000;           % number of dt steps to simulate
r1 = rand(1,nTimeSteps);      % random number for monte carlo
timeStep = nan(1,nTimeSteps); % simulation time steps where steps occur
                              % (pre-allocate r1 and timeStep for speed)
Pos=5000;                        % Initial position   
Stepsize=10;                  % Size of the motor's step 
kT=4.11;                      % Boltzman constant (pN.nm)    
kappa=0.3;                    % Stiffness of the trap (nm/pN) 



% SIMULATION
s = 0;                        % number of steps taken
t = 1;                        % simulation time points, matlab arrays start at 1
Noise = 0;                    % Initializing noise parameter   
                  

while t < nTimeSteps,
    Noise = normrnd(0,sqrt(kT*kappa),1); % Generating noise random value 
    PosVec(t)=Pos + Noise;    % Especifying position and adding noise                
    TimeVec(t)=(t*dt)*0.1;    % Generating time vector to plot 
    if r1(1,t) < k*dt*(1-(k*dt))% if the random number is small than this value (lambda*time - lambda*time^2) 
        s = s + 1;            % take a step
        Pos=Pos-Stepsize;     % Increment the position by one step size
        timeStep(s) = t;      % mark the simulation time the step happened
    end
    t = t + 1;                % increase simulation time
end

close all;
hfig = 1;
figure(hfig); clf;
plot(TimeVec,PosVec,'-');
fontSize = 10;
set(gca,'fontsize',fontSize);
set(gca,'linewidth',1);
set(gca,'layer','top');
box off;
set(hfig, 'PaperSize', [3 2.5]);
set(hfig, 'PaperPosition', [0.25 0.25 2.5 2]);
ylabel('Position, {\it bp}')
xlabel('Time, {\it s}');

% EXPONENTIAL DISTRIBUTION
% confirm the delay between steps fits the appropriate exponential distribution
%hfig = 2;
%figure(hfig); clf;
%t1 = 0.25:0.25:10;            % bins for plots and histogram
%plot(t1,hist(diff(timeStep*dt),t1)/sum(hist(diff(timeStep*dt),t1))/diff(t1(1:2)),'ok','markersize',4);
%hold on;
%plot([0 t1], k * exp(-k .* [0 t1]),'-r','linewidth',1.5);
%fontSize = 10;
%set(gca,'fontsize',fontSize);
%set(gca,'linewidth',1);
%set(gca,'layer','top');
%box off;
%set(hfig, 'PaperSize', [3 2.5]);
%set(hfig, 'PaperPosition', [0.25 0.25 2.5 2]);
%ylabel('probability density, {\it P \prime}')
%xlabel('time, {\it t}');
%set(gca,'xtick',0:2:10);

% POISSON DISTRIBUTION

% first calculate the distribution of events in the given amount of time
% using a sliding window
%timeStepWindow = 100;
%nWindows = nTimeSteps - timeStepWindow;
%num = zeros(1,nWindows);
%for i = 1:nWindows,
%   num(i) = length(intersect(i:i+timeStepWindow,timeStep));
%end

% plot the distribution and confirm that it fits to the appropriate
% Poisson distribution
%hfig = 3;
%figure(hfig); clf;
%bins = 0:1:15;
%bar(bins,hist(num,bins)/sum(hist(num,bins)),'facecolor',[0.4 0.5 0.8]);
%hold on;
%plot(bins,poisspdf(bins,k*timeStepWindow*dt),'-r','linewidth',1.5);
%fontSize = 10;
%set(gca,'fontsize',fontSize);
%set(gca,'linewidth',1);
%set(gca,'layer','top');
%box off;
%set(hfig, 'PaperSize', [3 2.5]);
%set(hfig, 'PaperPosition', [0.25 0.25 2.5 2]);
%ylabel('probability, {\it P}')
%xlabel('number of events, {\it n}');

% TRAJECTORY
%hfig = 4;
%figure(hfig); clf;
%nEvents = 50;       % show only the first 50 steps
%stairs([0 timeStep(1:nEvents)],[0 1:nEvents],'-k','linewidth',1);
%fontSize = 10;
%set(gca,'fontsize',fontSize);
%set(gca,'linewidth',1);
%set(gca,'layer','top');
%box off;
%set(hfig, 'PaperSize', [3 2.5]);
%set(hfig, 'PaperPosition', [0.25 0.25 2.5 2]);
%xlabel('time, {\it t}');
%ylabel('number of events');
