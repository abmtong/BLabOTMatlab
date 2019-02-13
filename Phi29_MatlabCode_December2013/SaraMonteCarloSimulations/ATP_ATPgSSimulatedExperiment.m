function [Nmin DwellTimes] = ATP_ATPgS_SimulatedExperiment()
% In this simulation you plug rate constants to obtain a simulated phage
% packaging experiment. The experiment is based on a scheme were one subunit releases ADP and
% binds ATP one by one with a reversible step - tight binding of ATP.
% In this simulation you first select a ATP concentration; Default is 500
% uM.
% The rate constant were taken from Chistol, Liu et al., Cell.  2012
%
%
% Sara June 2014
%
%
%
    
    ATP = 500; % This is the list of ATP conditions to titrate
    ATPgS = 1;
    ADP = 0; %(No ADP in solution)
    ATP_on   = 4; % (3.3 uM^-1 s^-1) 
    ADP_on   = 1.0; % (1.0 uM^-1 s^-1)
    ATPgS_on   = 4; % (3.3 uM^-1 s^-1) 
    Tatp_off = 1; % (kATP_off = 20 s^-1, 0.05) 
    Tatpgs_off = 0.05;
    Tadp_off = 0.028; % (kADP_off = 40 s^-1, 0.025)
    AlphaT = 10; % this means the special subunit has 10 times higher affinity for ATP than the rest of the subunits
    AlphaTb = 10;
    AlphaD = 0.1; % this means the special subunit releases ADP 10 slower than the rest of the subunits
    Tatp_tight = 0.0002; % (kATP_tight = 5000 s^-1, 0.0002)
    Tatpgs_tight = 4;
    Nrounds = 1000; %number of simulation rounds
    
    % Definining all the vectors that are used in this simulation
    DwellTimes = [];
    Nmin = [];
    N_mean = [];
    N_upper = [];
    N_lower = [];
    
   

    Tatp_on = 1/(ATP_on*ATP); %the loosely bind time is inversely proportional to ATP concentration
    Tatpgs_on = 1/(ATPgS_on*ATPgS); %the loosely bind time is inversely proportional to ATP concentration
        
            if ADP==0
                Tadp_on = NaN; % assigns infinite time for ADP to bind when there is no ADP in the experiment
            else
                Tadp_on = 1/(ADP_on*ADP); %the ADP binding time is inversely proportional to ADP concentration
            end
            
            [Nmin DwellTimes]=MonteCarlo_Simulating5Subunits_withATPgS(ATP,ATPgS,Tatp_on,Tatpgs_on,Tatp_off,Tatpgs_off,Tadp_on,Tadp_off,Tatp_tight,Tatpgs_tight,AlphaT,AlphaD,AlphaTb,Nrounds); 
                               % goes to this matlab script to compute the
                               % dwell duration distribution by first
                               % computing the time for each event
            N_mean= Nmin(2); %Nmin mean
            N_error=Nmin(3)-Nmin(1); % computes the error in terms of the confidence interval Nmin(3) is the upper limit and Nmin(1) es the lower one.
           
            
    Vel=0; % initializes the variable
    i=1;      % initializes the variable
    PauseCounter=0;
    while i<length(DwellTimes)   % loop to compute the velocity, each velocity value is 10/(tdwell+tburst) tburst is set to tb=8 ms by default and is considered constante for all conditions
        Vel=Vel+10/(DwellTimes(i)+0.008); % sums all instantanous velocities
        if (DwellTimes(i)>1)
            PauseCounter=PauseCounter+1;
        end
        i=i+1; % increases variable
    end
    [l m u]=uCalculateMeanDwellConfInt(DwellTimes,1000,0.95);
    
    %Vel_error=(1/(m*m))*(u-l)/2; % Computes the error for the velocity
    %Vel=Vel/length(DwellTimes); % averages all instantaneous velocities
 PauseCounter;
    
    
    
end