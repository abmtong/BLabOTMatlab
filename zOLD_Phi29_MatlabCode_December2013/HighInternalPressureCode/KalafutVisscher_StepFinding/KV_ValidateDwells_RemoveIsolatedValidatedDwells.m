function ValidatedDwells = KV_ValidateDwells_RemoveIsolatedValidatedDwells(ValidatedDwells)
    % If there are any isolated Dwells, remove them completely, 
    % They are not useful since we're not all that sure about their duration
    % and they don't have a valid step-size associated with them
    %
    % USE: ValidatedDwells = KV_ValidateDwells_RemoveIsolatedValidatedDwells(ValidatedDwells)
    %
    % Gheorghe Chistol, 30 Jun 2011
    
    DwellClusterIndex    = []; %the list of indices of all dwells that belong to the current dwell cluster
    ListOfDwellsToRemove = []; %compile a list of validated dwells that we have to throw away

    NminCluster = 2; %the cluster needs to have at least 2 temporally consecutive dwells, this limit can be increased to 3 or more if needed

    vd=1; %start with the very first Validated Dwell
    while vd <= length(ValidatedDwells) %scan forward only

        %check if the current dwell is temporally consecutive with respect to
        %the last dwell (if there is a last dwell)

        if vd==1 %this is the very first dwell
            DwellClusterIndex = vd;
        else %this is not the first dwell
            %we need to check that the current dwell is immediately after the last dwell in the dwell cluster
            if ValidatedDwells(vd).Start == ValidatedDwells(DwellClusterIndex(end)).Finish+1
                %the current dwell belongs to the ongoing dwell cluster
                DwellClusterIndex(end+1) = vd; %add the current dwell to the cluster index list
            else %the current dwell doesn't belong to the existing cluster

                if length(DwellClusterIndex)<NminCluster
                    %if the existing cluster is too small, cancel all the validated dwells within the existing cluster
                    ListOfDwellsToRemove = [ListOfDwellsToRemove DwellClusterIndex]; %clear those validated dwells, they are statistically useless
                end
                DwellClusterIndex = vd;  %reset the clusterSize to just one - the last dwell we just looked at
            end
        end

        %if the very last dwell is isolated, add it to the ListOfDwellsToRemove
        if vd == length(ValidatedDwells) && length(DwellClusterIndex)==1
            ListOfDwellsToRemove = [ListOfDwellsToRemove DwellClusterIndex];
            DwellClusterIndex    = []; %well, this is irrelevant now
        end

        vd = vd+1; %increment Validated Dwell counter
    end

    ValidatedDwells(ListOfDwellsToRemove) = []; %kill those useless lonely dwells
    
end