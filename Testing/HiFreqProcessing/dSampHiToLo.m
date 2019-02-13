function dSampHiToLo(Finit, Fend, Decimate)
%Downsamples a 50Khz phage data to a 2.5kHz data

narginchk(2,inf)

if nargin <3 || isempty(Decimate)
    Decimate = 0; %Filter, not decimate
end

dec = ceil(Finit/Fend);
[files, path] = uigetfile('','MultiSelect','on');

if ~iscell(files)
    files = {files};
end

outdir = [path filesep 'dSampData' filesep];
if ~exist(outdir, 'dir')
    mkdir(outdir)
end

for i = 1:length(files)
    load([path filesep files{i}])
    fnames = fieldnames(stepdata);
    for j = 1:length(fnames)
        fn = fnames{j};
        if iscell(stepdata.(fn))
            for k = length(stepdata.(fn)):-1:1
                %Downsample / Decimate the data
                if Decimate
                    stepdata.(fn){k} = windowFilter(@mean, stepdata.(fn){k}, 0, dec);
                else
                    stepdata.(fn){k} = windowFilter(@mean, stepdata.(fn){k}, [], dec);
                end
                if isempty(stepdata.(fn){k})
                    %Some traces, length < dec - returns empty - remove them (else throws error with e.g. @cellfun)
                    stepdata.(fn)(k) = [];
                end
            end
        end
    end
    if Decimate
        str = 'Decimated';
    else
        str = 'Downsampled';
    end
    dSampInfo.type = str;
    dSampInfo.Finit = Finit;
    dSampInfo.Fend = Fend;
    stepdata.dSampInfo = dSampInfo;
    
    fprintf('%s %s, Now saving... ', str, files{i})
    save([path filesep 'dSampData' filesep files{i}],'stepdata');
    fprintf('Done.\n')
end

%I thought taht 7.5e3>2.5e3 (raw) meant something in processed data, apparently it doesn't
% function outData = dSamp(inData)
% %50kHz, to 7.5kHz averaged to 2.5kHz. Just change frequencies in dec, dT, and averaging number wid to change.
% dec = ceil(50e3/2.5e3); %20
% dT = floor(50e3/7.5e3); %6
% wid = 3;
% len = length(inData);
% outData = zeros(1,floor(len/20));
% for i = 1:length(outData)
%     ran = i*dec*[1 1 1] - dT*(0:wid-1);
%     outData(i) = mean( inData(ran) );
% end