function out = RPpass_xwlc_batch(p)

%Select folder
if nargin < 1
    p = uigetdir();
end

%Get files
dd = dir(p);
nams = {dd(~[dd.isdir]).name};

%These have naming:

%{
ForceExtensionMMDDYYN##.mat
ForceExtensionMMDDYYN## RossWT PM.mat
%}

%Matlab sort doesn't handle 99 > 100 sorting, so let's sort on our own ?
% Lets convert to %03d and sort with that fileame
%ForceExtension010203N12 vs ForceExtension010203N123  
len = length(nams);
namssort = nams;
for i = 1:len
    if namssort{i}(24) == '.' ||  namssort{i}(24) == ' '
        namssort{i} = [namssort{i}(1:21) '0' namssort{i}(22:end)];
    end
end
%Sort with this %03d name..
[~, si] = sort(namssort);
%So we can sort the file list to be 'Windows-style'
nams = nams(si);

%Passive data has 'RossWT PM' at the end, so mark (dont have it = is pulling data)
ispull = cellfun(@isempty, strfind( nams, ' RossWT PM') );

%Store current pulling/passive index
curpull = 1;
%Each pulling is before the following passives (may be more than one)

len = length(nams);
out = cell(1,len);
%So let's go through every file in the list...
for i = 1:len
    %Check if this file is a pull or a passive file
    if ispull(i)
        %If the file is a pulling curve, update pulling index
        curpull = i;
    else
        %Else this is a passive mode file, so analyze
        fppull = fullfile(p, nams{curpull});
        fppass = fullfile(p, nams{i});
        try
            close all
            out{i} = RPpass_xwlc(fppull, fppass);
            drawnow
            fprintf('Processed passive file: %s with pulling: %s.\n', nams{i}(15:end), nams{curpull}(15:end))
        catch err
            %Filepair failed, warning message
            warning('Data with pulling file: %s and passive file: %s failed for reason: %s. Skipping', nams{curpull}(15:end), nams{i}(15:end), err.identifier)
            drawnow
        end
    end
end
out = [out{:}];
