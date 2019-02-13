function [Nmin DwellTimes] = ATPTitrationSimulatedExperiment()
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
    
    ATP = [10 50 100 500]; % This is the list of ATP conditions to titrate
  
    ADP = 0; %(No ADP in solution)
    ATP_on   = 4; % (3.3 uM^-1 s^-1) 
    ADP_on   = 1.0; % (1.0 uM^-1 s^-1)
   
    Tatp_off = 0.05; % (kATP_off = 20 s^-1, 0.05) 
   
    Tadp_off = 0.028; % (kADP_off = 40 s^-1, 0.025)
    AlphaT = 10; % this means the special subunit has 10 times higher affinity for ATP than the rest of the subunits
    AlphaTb = 10;
    AlphaD = 0.1; % this means the special subunit releases ADP 10 slower than the rest of the subunits
    Tatp_tight = 0.0002; % (kATP_tight = 5000 s^-1, 0.0002)
    
    Nrounds = 1000; %number of simulation rounds
    
    % Definining all the vectors that are used in this simulation
    DwellTimes = [];
    Nmin = [];
    N_mean = [];
    N_upper = [];
    N_lower = [];
    
   for t=1:length(ATP)

    Tatp_on = 1/(ATP_on*ATP(t)); %the loosely bind time is inversely proportional to ATP concentration
   
        
            if ADP==0
                Tadp_on = NaN; % assigns infinite time for ADP to bind when there is no ADP in the experiment
            else
                Tadp_on = 1/(ADP_on*ADP); %the ADP binding time is inversely proportional to ADP concentration
            end
            
            [Nmin DwellTimes]=MonteCarlo_Simulating5Subunits(Tatp_on,Tatp_off,Tadp_on,Tadp_off,Tatp_tight,AlphaT,AlphaD,AlphaTb,Nrounds); 
                               % goes to this matlab script to compute the
                               % dwell duration distribution by first
                               % computing the time for each event
            N_mean(t)= Nmin(2); %Nmin mean
            N_error(t)=Nmin(3)-Nmin(1); % computes the error in terms of the confidence interval Nmin(3) is the upper limit and Nmin(1) es the lower one.
           
            
    Vel(t)=0; % initializes the variable
    i=1;      % initializes the variable

    while i<length(DwellTimes)   % loop to compute the velocity, each velocity value is 10/(tdwell+tburst) tburst is set to tb=8 ms by default and is considered constante for all conditions
        Vel(t)=Vel(t)+10/(DwellTimes(i)+0.008); % sums all instantanous velocities
        i=i+1; % increases variable
    end
    Vel_error(t)=std(DwellTimes); % Computes the error for the velocity
    Vel(t)=Vel(t)/length(DwellTimes); % averages all instantaneous velocities
 
   end
   
    %plots the results
    close all;
    figure('Position',[500          200        800         400]);
    errorbar(ATP,N_mean,N_error);
    set(gca,'xscale','log')
    figure('Position',[400          200        800         400]);
    errorbar(ATP,Vel,Vel_error); hold on;  
    
    %fits the velocity to a Michaelis Menten Curve
    fitOpts = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0 0],...
    'Upper',[80 200],...
    'Startpoint',[40 120]);
    eqn = 'v*x/(k+x)';
    fitType = fittype(eqn,'indep','x','options',fitOpts);
    [fitRes,gof] = fit(ATP',Vel',fitType);
    KmValue=['Km Value is = ' Num2Str(fitRes.k)];
    VmaxValue=['Vmax value is = ' Num2Str(fitRes.v)];
    text(900,45,KmValue,'FontSize',8,'Color','k');
    text(900,55,VmaxValue,'FontSize',8,'Color','k');
    plot(fitRes);
    
    
end