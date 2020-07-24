function SimulateData

% PARAMETERS AND INITIALIZATION
k = 3.0;                      % rate (in "real units", s^-1)      %??? why this rate (supposedly the rate of the step is once every 0.5 seconds)
dt = 0.0004;                    % simulation dt, make small such that k*dt < 0.2      % why this dt? (you want to sample once every 0.1 seconds if it gave one step)
nTimeSteps = 10000;           % number of dt steps to simulate
r1 = rand(1,nTimeSteps);      % random number for monte carlo
timeStep = nan(1,nTimeSteps); % simulation time steps where steps occur
                              % (pre-allocate r1 and timeStep for speed)
Pos=5000;                        % Initial position   
Stepsize=2.5;                  % Size of the motor's step 
kT=4.11;                      % Boltzman constant (pN.nm)    
kappa=0.3;                    % Stiffness of the trap (nm/pN) 



% SIMULATION
s = 0;                        % number of steps taken
t = 1;                        % simulation time points, matlab arrays start at 1
Noise = 0;                    % Initializing noise parameter   
ATPs=0;      


while t < nTimeSteps,
    Noise = normrnd(0,sqrt(kT*kappa),1); % Generating noise random value 
    PosVec(t)=Pos + Noise;    % Especifying position and adding noise                
    TimeVec(t)=(t*dt)*100;    % Generating time vector to plot 
    if r1(1,t) < k*dt*(1-(k*dt))% if the random number is small than this value (lambda*time - lambda*time^2) 
        ATPs=ATPs+1  ;          
        if ATPs == 1 ;         % Stepping Only happens when 5 molecules bind ATP
            s = s + 1;            % take a step
            Pos=Pos-Stepsize;     % Increment the position by one step size
            timeStep(s) = t;      % mark the simulation time the step happened
            ATPs=0;
        end
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