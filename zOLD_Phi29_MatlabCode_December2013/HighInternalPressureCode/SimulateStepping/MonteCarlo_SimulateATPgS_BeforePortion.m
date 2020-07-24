function Results=MonteCarlo_SimulateATPgS_BeforePortion(DwellTimeDistribution)
% Simulate data for the portion immediately before an ATPgS pause cluster.
% There are two scenarios to simulate: hydrolysis occurs in the dwell and
% hydrolysis occurs in the burst. The second case is more interesting and
% its results may not be completely intuitive
%
% We will start with 3x normal dwells at x1=0bp, x2=9.6bp, x3=2*9.6bp 
% We will add a normal dwell at x=-9.6bp-n*2.4bp where n=0, 1, 2, 3 to
% simulate an incomplete burst
%
%
% Gheorghe Chistol, 18 July 2011

%% Set the Analysis Path and the path for the Kalafut-Visscher method
addpath(['D:\Phi29\MatlabCode\MatlabFilesGhe\MatlabGeneral\HighInternalPressureCode\' filesep 'KalafutVisscher_StepFinding' filesep], '-end'); %where the KV scripts are located
addpath(['D:\Phi29\MatlabCode\MatlabFilesGhe\MatlabGeneral\HighInternalPressureCode\' filesep], '-end'); %where other scripts are located

%% Define the parameters
NoiseRms =  35;
%BurstDuration = 0.02; %in seconds
Bandwidth = 2500; %in Hz 
StartY = 2.*10;
Nsim   = 100; %number of simulations

%normalize the DwellTime distribution just in case
DwellTimeDistribution.p = DwellTimeDistribution.p/sum(DwellTimeDistribution.p);
DwellTimeDistribution.t = 1*DwellTimeDistribution.t;
Results = [];
% Results(s).RawTime 
% Results(s).RawCont

LastTranslocationStep = [2.5 2*2.5 3*2.5 4*2.5 4*2.5];
%LastTranslocationStep = [2.5 2*2.5 3*2.5 4*2.5];
%LastTranslocationStep = [4*2.5 4*2.5];

for s = 1:Nsim %s stands for "Simulation" index
    for n=1:1:length(LastTranslocationStep)  %how many 2.4 steps will be added
        %initial conditions
        Time = 0;
        Cont = StartY;
        TranslocationStep = [10 10 10 ];

        
        %keep adding extra steps until contour reaches desired stop
        for t = 1:length(TranslocationStep)+1
            %add the dwell portion
            DwellTime = MonteCarlo_DrawFromDwellTimeDistribution(DwellTimeDistribution);
            Npts      = round(DwellTime*Bandwidth); %number of points to add to the current dataset
            Time      = [Time Time(end)+1/Bandwidth*(1:1:Npts) ];
            Cont      = [Cont Cont(end)*ones(1,Npts)];

            %add the burst portion
            if t<=length(TranslocationStep)
                Cont(end) = Cont(end)-TranslocationStep(t);
            else
                Cont(end) = Cont(end)-LastTranslocationStep(n);
            end
        end
        DwellTime = 0.5-DwellTime;
        Npts      = round(DwellTime*Bandwidth); %number of points to add to the current dataset
        Time      = [Time Time(end)+1/Bandwidth*(1:1:Npts) ];
        Cont      = [Cont Cont(end)*ones(1,Npts)];

        %now add the simulated noise
        Noise = NoiseRms*rand(1,length(Time));
        Noise = Noise-mean(Noise); %noise must be centered on zero
        Cont  = Cont+Noise;

        %% Plot the Simulated Data
        F=figure('Units','normalized','Position',[0.0029    0.2174    0.4941    0.6484]); 
        A = axes('Position',[0.1 0.1100 0.5633 0.8150],'Box','on','FontSize',16);
        hold on;
        plot(Time,Cont,'Color',0.8*[1 1 1]);
        FiltTime = FilterAndDecimate(Time,10);
        FiltCont = FilterAndDecimate(Cont,10);
        plot(FiltTime,FiltCont,'Color',0.4*[1 1 1],'LineWidth',1.5);
        axis([0 2 -30 30]);
        xlabel('Time (s)');
        ylabel('DNA Contour Length (bp)');
        set(gca,'YGrid','on','YTick',-20:10:30);
        
        %% Plot the Kernel Density
        B = axes('Position',[0.7 0.1100 0.3185 0.8150],'Box','on','FontSize',16);
        KernelFiltFact = 20;
        [KernelX KernelY] = KV_CalculateCustomKernelDensity(Cont,KernelFiltFact); 
        area(KernelX,KernelY,'FaceColor',rgb('Gold'),'LineWidth',1);

        set(gca,'YLim',[0 1.1]);
        set(gca,'XLim',[-40 40]);
        set(gca,'XGrid','on','XTick',-9.6:9.6:25,'XTickLabel',{});
        set(gca,'YTick',[]);
        camroll(90);   
         
        Results(end+1).Time = Time;
        Results(end).Cont   = Cont;
        Results(end).KernelX = KernelX;
        Results(end).KernelY = KernelY;
        %pause(0.1);
        close(F);
    end
end
