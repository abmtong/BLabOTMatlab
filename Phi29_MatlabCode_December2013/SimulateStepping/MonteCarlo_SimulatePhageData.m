function stepdata=MonteCarlo_SimulatePhageData(DwellTimeDistribution)
% This function will generate phage stepping simulated data
% NoiseRms: define the RMS of the simulated noise (for contour length)
% Freq7p5: frequency of 7.5bp bursts, 0 to 1 range
% DwellTimeDistribution: DTD.t and DTD.p, sum(DTD.p)=1 is the condition
% BurstDuration: default is around 10msec
% LengthFC: the length (in bp) of the feedback cycle to be generated
% NumberFC: the number of feedback cycles to be generated
% The default bandwidth is 2500Hz
%
% Gheorghe Chistol, 06 June 2011
NoiseRms = 30;
Freq7p5 = 0.9; %0 to 1 range
BurstDuration = 0.020; %in seconds
Bandwidth = 2500; %in Hz
NormalBurst = 10; %in bp
ShortBurst  = 7.5; %in bp
LengthFC = 150; %in bp
NumberFC = 25; %how many feedback cycles

%normalize the DwellTime distribution just in case
DwellTimeDistribution.p = DwellTimeDistribution.p/sum(DwellTimeDistribution.p);

stepdata.time = {};
stepdata.contour = {};

for fc = 1:NumberFC
    Time = 0;
    Contour = LengthFC; %start at a given length then "translocate" down to zero
    
    %keep adding extra steps until contour crosses under zero
    while Contour(end)>0 
        %Decide what step-size will be taken right now
        temp = rand;
        if temp<Freq7p5
            StepSize = ShortBurst;
        else
            StepSize = NormalBurst;
        end
        
        %add the dwell portion
        DwellTime = MonteCarlo_DrawFromDwellTimeDistribution(DwellTimeDistribution);
        Npts      = round(DwellTime*Bandwidth); %number of points to add to the current dataset
        Time      = [Time    Time(end)+1/Bandwidth*(1:1:Npts) ];
        Contour   = [Contour Contour(end)*ones(1,Npts)];
        
        %add the burst portion
        Npts      = round(BurstDuration*Bandwidth); %number of points to add to the current dataset
        Time      = [Time    Time(end)+(1/Bandwidth)*(1:1:Npts) ];
        temp      = interp1([0 BurstDuration],[0 -StepSize],1/Bandwidth*(1:1:Npts));
        Contour   = [Contour Contour(end)+temp];
    end
    
    %now add the simulated noise
    Noise = NoiseRms*rand(1,length(Time));
    
    stepdata.time{fc} = Time;
    stepdata.contour{fc} = Contour+Noise;
end