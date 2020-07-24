function LocalMaxima = KV_IdentifyLocalMaxima(x, y, ContrastThr)
    % Use the Custom Kernel Density to identify valid peaks and organize
    % information about them, which will later be used to validated dwell
    % candidates
    % x - kernel grid
    % y - kernel density value
    %
    % LocalMaxima = KV_IdentifyLocalMaxima(x, y, ContrastThr)
    %
    % Gheorghe Chistol, 6 July 2011

    % LocalMaxima.KernelGrid  = x;
    % LocalMaxima.KernelValue = y;
    % LocalMaxima.LocalMaxInd(m)      - for the m-th local maximum
    % LocalMaxima.LeftLocalMinInd(m)  - for the m-th local maximum
    % LocalMaxima.RightLocalMinInd(m) - for the m-th local maximum
    % LocalMaxima.Baseline(m)         - for the m-th local maximum
    % LocalMaxima.PeakContrast(m)     - for the m-th local maximum
    % LocalMaxima.IsValid(m)          - for the m-th local maximum
    % LocalMaxima.LocalMinInd - the list of indices of all local minima

    LocalMaxInd = [];
    for i=2:length(y)-1
        if (y(i)>y(i-1)) && (y(i)>y(i+1))
            %we got a local max
            LocalMaxInd(end+1)=i;
        end
    end

    LocalMinInd = [];
    for i=2:length(y)-1
        if (y(i)<y(i-1)) && (y(i)<y(i+1))
            %we got a local max
            LocalMinInd(end+1)=i;
        end
    end

    % Add the very first and very last local minima
    LocalMinInd = [find(y>0,1,'first') LocalMinInd find(y>0,1,'last')];

    %% For Each LocalMaxima check the height of the LeftMin and RightMin 
    %compare to the height of the LocalMax 
    MinimumContrast = median(abs(diff(y)))/median(y)+1;
    m=1;
    while m <=length(LocalMaxInd)
        LeftMinH  = y(LocalMinInd(m));
        RightMinH = y(LocalMinInd(m+1));
        LocalMaxH = y(LocalMaxInd(m));

        LocalMaxContr = LocalMaxH./[LeftMinH RightMinH];

        %locate peaks with insufficient contrast
        if min(LocalMaxContr) < MinimumContrast
            LocalMaxInd(m) = ''; %remove the current local maximum index

            %now we need to remove the corresponding local min index, the larger one of [LeftMinH RightMinH]
            if LeftMinH>RightMinH
                LocalMinInd(m) = ''; %remove the corresponding local min index
            else
                LocalMinInd(m+1) = ''; %remove the corresponding local min index
            end
            %no need to increment m
        else
            m=m+1; %increment m since nothing happened
        end
    end

    %% Organize the LocalMaxima data structure
    LocalMaxima.KernelGrid  = x;
    LocalMaxima.KernelValue = y;
    LocalMaxima.LocalMaxInd = LocalMaxInd;
    LocalMaxima.LeftLocalMinInd  = []; %for each LocalMaxima.LocalMaxInd(i) there is a corresponding LocalMaxima.LeftLocalMinInd(i) 
    LocalMaxima.RightLocalMinInd = []; %and a LocalMaxima.RightLocalMinInd(i) respectively
    LocalMaxima.IsValid          = []; %0 if it's not valid, 1 if it's valid

    for m=1:length(LocalMaxInd)
        LocalMaxima.LeftLocalMinInd(m)  = LocalMinInd(m);
        LocalMaxima.RightLocalMinInd(m) = LocalMinInd(m+1);
        Xtemp = [x(LocalMinInd(m)) x(LocalMinInd(m+1))];
        Ytemp = [y(LocalMinInd(m)) y(LocalMinInd(m+1))];
        Xpeak = x(LocalMaxInd(m));
        LocalMaxima.Baseline(m)     = interp1(Xtemp,Ytemp,Xpeak);
        LocalMaxima.PeakContrast(m) = y(LocalMaxInd(m))/LocalMaxima.Baseline(m);
        
        if LocalMaxima.PeakContrast(m) > ContrastThr
            LocalMaxima.IsValid(m) = 1;
        else
            LocalMaxima.IsValid(m) = 0;
        end
    end
    
    LocalMaxima.LocalMinInd = LocalMinInd;
    
end