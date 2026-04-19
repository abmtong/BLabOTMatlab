function stepdata = trimstepdata(stepdata, tlim)
%Trims out the data within the time indicies tlim

%Create function handles that find start/end index of pts in crop
cellfindst = @(ce) (find(ce > tlim(1),1));
cellfinden = @(ce) (find(ce < tlim(2),1, 'last'));
indst = cellfun(cellfindst, stepdata.time, 'UniformOutput', false);
inden = cellfun(cellfinden, stepdata.time, 'UniformOutput', false);

%Also handle fluorescence, specially after

%We're going to put these in the cut field. If it doesn't exist, we'll make it [later]
if ~isfield(stepdata, 'cut')
    newcut = 1;
else
    newcut = 0;
end
cutadd = cell(1,length(indst));

%Act over each structure field
fnames = fieldnames(stepdata);
for j = 1:length(fnames)
    %For those that are cells, ...
    if iscell(stepdata.(fnames{j})) && isnumeric(stepdata.(fnames{j}){1})
        temp = stepdata.(fnames{j});
        %Skip fields that start apd -- this is probably just apdcol
        if strncmp(temp, 'apd', 3)
            continue
        end
        %Trim
        for k = length(indst):-1:1 %process in reverse so cell removal, e.g. a(3) = [], doesn't disrupt indicies
            %Check that there are actually points to remove
            st = indst{k};
            en = inden{k};
            if ~isempty(st) && ~isempty(en)
                temp2 = temp{k};
                ln = length(temp2);
                %Different cases depending on what is removed
                if st ==1 && en == ln
                    %Entire removal
                    cutadd(k) = temp(k);
                    temp(k) = [];
                    continue
                elseif st ~= 1 && en ~= ln
                    %Middle removal, need to segment in two
                    left = temp2(1:st);
                    cutadd{k} = temp2(st+1:en-1);
                    right = temp2(en:end);
                    temp = [temp(1:k-1) {left right} temp(k+1:end)];
                else
                    %Half removal
                    cutadd{k} = temp2(st:en);
                    temp2(st:en) = [];
                    temp{k} = temp2;
                end
            end
        end
        %Save back this new one
        stepdata.(fnames{j}) = temp;
        %Add cut bits to the end of the cut array
        cutadd = cutadd(~cellfun(@isempty,cutadd));
        if newcut
            stepdata.cut.(fnames{j}) = cutadd;
        else
            stepdata.cut.(fnames{j}) = [stepdata.cut.(fnames{j}) cutadd];
        end
    end
end

%Fluorescence
if isfield(stepdata, 'apdT')
    apdrm = stepdata.apdT > tlim(1) & stepdata.apdT < tlim(2);
    stepdata.apdT(apdrm) = [];
    %Crop
    for i = 1:3 %3 max APDs
        fn = sprintf('apd%d',i);
        if isfield(stepdata, fn)
            stepdata.(fn)(apdrm) = [];
        end
    end
end

%Fluorescence LaserChoice
if isfield(stepdata, 'apdcolT')
    apdcolrm = stepdata.apdcolT > tlim(1) & stepdata.apdcolT < tlim(2);
    stepdata.apdT(apdcolrm) = [];
    %Crop
    for i = 1:numel(stepdata.apdcol)
        stepdata.apdcol{i}(apdcolrm) = [];
    end
end
