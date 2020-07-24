function [Nmin DwellTimes] = Titrate_ATPonly()
%
%
    ATP = [1/6  1/3 1/2 1 2 3 8 16 30];
    ADP = 0;
    Tadp     = 20;
    
    Tatp     = 20;
    Tatp_off = 50; 
    Tadp_off = 50;
    AlphaT = 2.2;
    AlphaD = 3.5;
    Tatp_tight = 1;
    Nrounds = 1000; %number of simulation rounds
    DwellTimes = [];
    Nmin = [];
    N_mean = [];
    N_upper = [];
    N_lower = [];
    for t = 1:length(ATP)
        Tatp_on = Tatp/ATP(t); %the loose binding time is inversely proportional to ATP concentration
        
        for d = 1:length(ADP)
            if ADP(d)==0
                Tadp_on = NaN;
            else
                Tadp_on = Tadp/ADP(d); %the ADP binding time is inversely proportional to ADP concentration
            end
            
            [Nmin{t} DwellTimes{t}]=MonteCarlo_Simulating5Subunits(Tatp_on,Tatp_off,Tadp_on,Tadp_off,Tatp_tight,AlphaT,AlphaD,Nrounds);
            N_mean(t) = Nmin{t}(2);
            N_upper(t) = Nmin{t}(3)-Nmin{t}(2);
            N_lower(t) = Nmin{t}(2)-Nmin{t}(1);
        end
    end
    
    figure('Position',[1          45        1366         657]);
    errorbar(ATP,N_mean,N_lower,N_upper,'ob');
    xlabel('Normalized [ATP]');
    ylabel('Nmin');
    set(gca,'XScale','log');
    YLim = get(gca,'YLim');
    set(gca,'YLim',[0 YLim(2)]);
    title(['Tatp_on='    num2str(Tatp)   '/[ATP]; ' ...
           'Tatp_off='   num2str(Tatp_off)     '; ' ...
           'Tatp_tight=' num2str(Tatp_tight)   '; ' ...
           'Tadp_off='   num2str(Tadp_off)     '; ' ...
           'AlphaATP='   num2str(AlphaT)       '; ' ...
           'AlphaADP='   num2str(AlphaD)       '; ' ...
          ], 'Interpreter' ,'none');
end