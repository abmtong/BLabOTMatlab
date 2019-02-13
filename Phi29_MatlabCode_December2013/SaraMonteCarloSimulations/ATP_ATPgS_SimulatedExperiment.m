function [DwellTimes] = ATP_ATPgS_SimulatedExperiment()
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
    ATPgS_on   = 8; % (3.3 uM^-1 s^-1) 
    Tatp_off = 0.05; % (kATP_off = 20 s^-1, 0.05) 
    Tatpgs_off = 0.05;
    Tadp_off = 0.023; % (kADP_off = 40 s^-1, 0.025)
    AlphaT = 10; % this means the special subunit has 10 times higher affinity for ATP than the rest of the subunits
    AlphaTb = 10;
    AlphaD = 0.1; % this means the special subunit releases ADP 10 slower than the rest of the subunits
    Tatp_tight = 0.0002; % (kATP_tight = 5000 s^-1, 0.0002)
    Tatpgs_tight_off=4;
    Tatpgs_tight = 0.002;
    Nrounds = 1000; %number of simulation rounds
    Nmolecules = 25;
    PauseThreshold=1; % (sec)
    % Definining all the vectors that are used in this simulation
    DwellTimes = [];
    Nmin = [];
    N_mean = [];
    N_upper = [];
    N_lower = [];
    

    for n=1:Nmolecules

    Tatp_on = 1/(ATP_on*ATP); %the loosely bind time is inversely proportional to ATP concentration
    Tatpgs_on = 1/(ATPgS_on*ATPgS); %the loosely bind time is inversely proportional to ATP concentration
        
            if ADP==0
                Tadp_on = NaN; % assigns infinite time for ADP to bind when there is no ADP in the experiment
            else
                Tadp_on = 1/(ADP_on*ADP); %the ADP binding time is inversely proportional to ADP concentration
            end
            
            [ATPgsCounter DwellTimes]=MonteCarlo_Simulating5Subunits_withATPgS2(ATP,ATPgS,Tatp_on,Tatpgs_on,Tatp_off,Tatpgs_off,Tadp_on,Tadp_off,Tatp_tight,Tatpgs_tight,Tatpgs_tight_off,AlphaT,AlphaD,AlphaTb,Nrounds); 
                               % goes to this matlab script to compute the
                               % dwell duration distribution by first
                               % computing the time for each event
            %N_mean= Nmin(2); %Nmin mean
            %N_error=Nmin(3)-Nmin(1); % computes the error in terms of the confidence interval Nmin(3) is the upper limit and Nmin(1) es the lower one.
           
            
    Vel=0; % initializes the variable
    PauseCounter=0;
    i=1;      % initializes the variable
    
    
   
    %disp(PauseThreshold);
    ind=DwellTimes>PauseThreshold;
    
    Pauses=DwellTimes(ind);
    PauseCounter=length(Pauses);
    
    RegularDwells=DwellTimes(~ind);
        
    
    while i<length(DwellTimes)   % loop to compute the velocity, each velocity value is 10/(tdwell+tburst) tburst is set to tb=8 ms by default and is considered constante for all conditions
        if i<=length(RegularDwells)
        Vel=Vel+10/(RegularDwells(i)+0.008); % sums all instantanous velocities  
        end
        
        if i==1;
            Ypos(2*i-1)=Nrounds*10;
            Xpos(2*i-1)=0;
            Ypos(2*i)=Nrounds*10;
            Xpos(2*i)=Xpos(2*i-1)+(DwellTimes(i));
        elseif i<length(DwellTimes)-1
            Ypos(2*i-1)=Nrounds*10-i*10;
            Xpos(2*i-1)=Xpos(2*i-2);
            Ypos(2*i)=Nrounds*10-i*10;
            Xpos(2*i)=Xpos(2*i-1)+(DwellTimes(i));
        end
        
        i=i+1; % increases variable
       
    end
    
    Vel_error=sqrt(std(10./(RegularDwells+0.008))); % Computes the error for the velocity
    Vel=Vel/length(RegularDwells); % averages all instantaneous velocities   
    
    
   close all;
   figure;
   plot(Xpos,Ypos);
   %disp('Pause detection method counted the following number of pauses')
   %disp(PauseCounter)
   %disp('Pause density is : ')
   PauseDensity=(PauseCounter/Nrounds*10)*10;
   %disp(PauseDensity)
   pause(1);
   VecATPgSCounter(n)=ATPgsCounter;
   VecPauseDensity(n)=PauseDensity;
   VecPauseCounter(n)=PauseCounter;
   VecVel(n)=Vel;
   VecVel_error(n)=Vel_error;
    end
   
    close all
    h1=figure;
    axes1 = axes('Parent',h1,'FontSize',16);
    errorbar([1:1:Nmolecules],VecVel,VecVel_error);
    xlabel('Molecule number (a.u.)','FontSize',16)
    ylabel('Pause-free velocity (bp/s)','FontSize',16)
    ylim([50 150])
    meanVel=num2str(mean(VecVel));
    legend(['Vel= ' meanVel ' bp/s'],'show','FontSize',16)
    box(axes1,'on');
    hold(axes1,'all');


    %figure;
    h2=figure;
    axes2 = axes('Parent',h2,'FontSize',16);
    VecErrorPause=(sqrt(VecPauseCounter)/Nrounds*10)*10;    
    errorbar([1:1:Nmolecules],VecPauseDensity,VecErrorPause);
    ylim([0 5])
    xlabel('Molecule number (a.u.)','FontSize',16)
    ylabel('PauseDensity (bp/s)','FontSize',16)
    meanPause=num2str(mean(VecPauseDensity));
    legend(['Pause Density= ' meanPause ' 1/kb'],'show','FontSize',16);
    box(axes2,'on');
    hold(axes2,'all');


    %figure;
    h3=figure;
    axes3 = axes('Parent',h3,'FontSize',16);
    bar([1:1:Nmolecules],VecATPgSCounter-VecPauseCounter);
    ylim([-5 10])
    xlabel('Molecule number (a.u.)','FontSize',16)
    ylabel('Number of pauses (a.u.)','FontSize',16)
    Indicator=num2str(mean(VecATPgSCounter-VecPauseCounter));
    legend(['Indicator= ' Indicator '\newline undercounted (+) \newline overcounted (-)'],'show','FontSize',16)
    box(axes3,'on');
    hold(axes3,'all');

    
end