function FragDwellInd = KV_FragmentTraceAtSlips(DwellInd)
    % Break up the trace into fragments where slips occurs. Slips prevent us
    % from deploying the side-histogram analysis properly, and fragmenting the
    % trace gets around that.
    %
    % FragDwellInd{1}, FragDwellInd{2} etc for each fragment
    %
    % DwellInd contains the following fields: (d stands for "Dwell")
    %                                          DwellInd(d).Start
    %                                          DwellInd(d).Finish
    %                                          DwellInd(d).Mean
    % FragDwellInd contains the following fields: (f stands for "Fragment")
    %                                          FragDwellInd{f}(d).Start
    %                                          FragDwellInd{f}(d).Finish
    %                                          FragDwellInd{f}(d).Mean
    %
    % Gheorghe Chistol, 6 July 2011

    FragDwellInd = {};

    %by default the first fragment must start at with the first dwell
    FragmentStartInd  = 1;

    for d = 1:length(DwellInd)-1
        %if the next dwell is higher than the current dwell (i.e. slip/backtrack)
        if DwellInd(d+1).Mean>DwellInd(d).Mean
           FragDwellInd{end+1} = DwellInd(FragmentStartInd:d); %current fragment ends at the dth dwell, right before the slip/backtrack
           FragmentStartInd    = d+1;
        end
    end
    
    %the leftover goes into the last fragment
    if FragmentStartInd<length(DwellInd)
       FragDwellInd{end+1} = DwellInd(FragmentStartInd:end); %current fragment ends at the dth dwell, right before the slip/backtrack
    end
    
    disp(['The current trace has ' num2str(length(FragDwellInd)) ' fragments']);
end