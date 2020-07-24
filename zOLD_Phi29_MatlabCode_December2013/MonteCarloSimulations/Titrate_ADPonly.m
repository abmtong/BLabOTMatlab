function [Nmin DwellTimes] = Titrate_ADPonly()
%
%
    ATP = 1;
    ADP = [0 1 2 3 4 6];
    Tadp     = 100;
    
    Tatp     = 20;
    Tatp_off = 50; 
    Tadp_off = 50;
    AlphaT = 10;
    AlphaD = 3.7;
    Tatp_tight = 5;
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
            
            [Nmin{d} DwellTimes{d}]=MonteCarlo_Simulating5Subunits(Tatp_on,Tatp_off,Tadp_on,Tadp_off,Tatp_tight,AlphaT,AlphaD,Nrounds);
            N_mean(d) = Nmin{d}(2);
            N_upper(d) = Nmin{d}(3)-Nmin{d}(2);
            N_lower(d) = Nmin{d}(2)-Nmin{d}(1);
        end
    end
    
    figure('Position',[1          45        1366         657]);
    errorbar(ADP,N_mean,N_lower,N_upper,'ob');
    xlabel('Normalized [ADP]');
    ylabel('Nmin');
    YLim = get(gca,'YLim');
    set(gca,'YLim',[0 YLim(2)]);
    title(['Tatp_on='    num2str(Tatp)   '/[ATP]; ' ...
           'Tatp_off='   num2str(Tatp_off)     '; ' ...
           'Tatp_tight=' num2str(Tatp_tight)   '; ' ...
           'Tadp_on='    num2str(Tadp)   '/[ADP]; ' ...           
           'Tadp_off='   num2str(Tadp_off)     '; ' ...
           'AlphaATP='   num2str(AlphaT)       '; ' ...
           'AlphaADP='   num2str(AlphaD)       '; ' ...
          ], 'Interpreter' ,'none');    
    %set(gca,'XScale','log');
    set(gca,'XScale','linear');
end