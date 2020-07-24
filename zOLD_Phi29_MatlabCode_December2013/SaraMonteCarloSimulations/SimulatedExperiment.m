function [Nmin DwellTimes] = SimulatedExperiment()
% In this simulation you plug rate constants to obtain a simulated phage
% packaging experiment. The experiment is based on a scheme were one subunit releases ADP and
% binds ATP one by one with a reversible step - tight binding of ATP.
% In this simulation you first select a ATP concentration; Default is 500
% uM.
% The rate constant were taken from Chistol, Liu et al., Cell.  2012
%
% Sara 06 2014
%
%
%
    
    ATP = 500; %(Saturating ATP conditions)
    ADP = 0; %(No ADP in solution)
    ATP_on   = 3.3; % (3.3 uM^-1 s^-1)
    ADP_on   = 1.0; % (1.0 uM^-1 s^-1)
    Tatp_off = 0.05; % (kATP_off = 20 s^-1) 
    Tadp_off = 0.025; % (kADP_off = 40 s^-1)
    AlphaT = 1;
    AlphaD = 1;
    AlphaTb = 10;
    Tatp_tight = 0.0002; %
    Nrounds = 1000; %number of simulation rounds
    DwellTimes = [];
    Nmin = [];
    N_mean = [];
    N_upper = [];
    N_lower = [];
    
        Tatp_on = 1/(ATP_on*ATP); %the loose binding time is inversely proportional to ATP concentration
        
     
            if ADP==0
                Tadp_on = NaN;
            else
                Tadp_on = 1/(ADP_on*ADP); %the ADP binding time is inversely proportional to ADP concentration
            end
            
            [Nmin DwellTimes]=MonteCarlo_Simulating5Subunits(Tatp_on,Tatp_off,Tadp_on,Tadp_off,Tatp_tight,AlphaT,AlphaD,AlphaTb,Nrounds);
            N_mean = Nmin(2);
            N_upper = Nmin(3);
            N_lower = Nmin(1);
            MeanDwell=uCalculateMeanDwellConfInt(DwellTimes,1000,0.95);
            D_mean = MeanDwell(2);
            D_upper = MeanDwell(3);
            D_lower = MeanDwell(1);
    
    close all;
    figure('Position',[1          45        1366         657]);
    hist(DwellTimes,30); 
    xlabel('Time (s)');
    ylabel('Frequency of events (a.u.)');
    YLim = get(gca,'YLim');
    set(gca,'YLim',[0 YLim(2)]);
    title(['[ATP] ='    num2str(ATP)        '; ' ...
           'Mean Dwell=' num2str(D_mean)        '; ' ...
           'Lower_Nmin=' num2str(D_lower)   '; ' ...
           'Upper Nmin=' num2str(D_upper)   '; ' ...
           'Nmin='   num2str(N_mean)        '; ' ...
           'Lower_Nmin=' num2str(N_lower)   '; ' ...
           'Upper Nmin=' num2str(N_upper)   '; ' ...
    ], 'Interpreter' ,'none');

Vel=0;
i=1;

while i<length(DwellTimes)
     Vel=Vel+10/(DwellTimes(i)+0.008);
     i=i+1;
end

Vel=Vel/length(DwellTimes);
disp(Vel);

end