function [LocalMaxInd LocalMinInd] = Pwd_IdentifyLocalMaxima(x, y, ContrastThr)
    % Use the Custom Kernel Density to identify valid peaks and organize
    % information about them, which will later be used to validated dwell
    % candidates
    % x - kernel grid
    % y - kernel density value
    %
    % [LocalMaxInd LocalMinInd] = Pwd_IdentifyLocalMaxima(x, y, ContrastThr)
    %
    % Gheorghe Chistol, 6 July 2011

    LocalMaxInd = [];
    for i=2:length(y)-1
        if (y(i)>=y(i-1)) && (y(i)>y(i+1)) || ...
           (y(i)>y(i-1)) && (y(i)>=y(i+1))
            %we got a local max
            LocalMaxInd(end+1)=i;
        end
    end

    LocalMinInd = [];
    for i=2:length(y)-1
        if ((y(i)<y(i-1)) && (y(i)<=y(i+1))) || ...
           ((y(i)<=y(i-1)) && (y(i)<y(i+1)))  %sometimes there may be two points at the minimum with the same y value     
            %we got a local min
            LocalMinInd(end+1)=i;
        end
    end

    % Add the very first and very last local minima
    %LocalMinInd = [find(y>0,1,'first') LocalMinInd find(y>0,1,'last')];
    if length(LocalMinInd)==length(LocalMaxInd)
        LocalMinInd(end+1) = length(y); %last point as the last min
    end
    %% For Each LocalMaxima check the height of the LeftMin and RightMin 
    %compare to the height of the LocalMax 
   
    m=1;

    while m <=length(LocalMaxInd)
        LeftMinH  = y(LocalMinInd(m));
        RightMinH = y(LocalMinInd(m+1));
        LocalMaxH = y(LocalMaxInd(m));

        LocalMaxContr = LocalMaxH./[LeftMinH RightMinH];

        %locate peaks with insufficient contrast
        if min(LocalMaxContr) < ContrastThr
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

end