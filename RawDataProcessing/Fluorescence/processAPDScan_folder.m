function processAPDScan_folder(inp)
%Looks through all .dats and saves .pngs of all confocal scans in the folder

if nargin < 1
    inp = uigetdir;
    if ~inp
        return
    end
end

%Instrument for loading options. Mostly relates to PSD scan, whether it will be i16 (Meitner) vs single (Avo)
op.Instrument = 'Meitner';
%Skip files that have any of these strings
strskip = {'_fl' '_pos' '_grn' '_green'};

%Get .dat files
d = dir(fullfile(inp, '*.dat'));
d = d(~[d.isdir]);
d = {d.name};

for i = 1:length(d)
    %Skip _fl, etc. files.
    tmp = cellfun(@(x) strfind(d{i}, x), strskip, 'Un', 0);
    if any([tmp{:}])
        continue
    end
    
    %Load
    fp = fullfile(inp,d{i});
    dat = loadfile_wrapper(fp, op);
    
    %Check if this has fluorescence data
    if ~isfield(dat, 'APDT')
        continue
    end
    
    %Check if this is a scan. Just check if it has the fields that processAPDScan needs
    meta = dat.meta;
    if any(~isfield(meta, {'scanNStepsX' 'apdNSampPerStep' 'scanStepsYorNScans'}))
        continue
    end
    try
        scn = processAPDScan(dat);
    catch
        warning('Scan %s failed- aborted scan?', d{i})
    end
    
    %Convert double
    scn = cellfun(@double, scn, 'Un', 0);
    %Autocontrast
    scn = cellfun(@(x) x/max(x(:)), scn, 'Un', 0);
    
    %Handle differently by nAPDs
    napd = length(scn);
    if napd == 3 %Avo 3-color
        img = zeros( size(scn{1},1), size(scn{1},2)*3 ,3);
        %B
        img(:,1:end/3,3) = scn{1};
        %G
        img(:,end/3+1:end*2/3,2)=scn{2};
        %R
        img(:,end*2/3+1:end,1)=scn{3};
    else %napd == 2
        %Create a new image of nxmx3 data
        img = zeros( size(scn{1},1), size(scn{1},2)*2 ,3);
        img(:,1:end/2,2) = scn{1};
        img(:,end/2+1:end,1)=scn{2};
    end
    
    %Save. Permute axes so it saves as a vertical stack
    img = permute(img, [2 1 3]);
    [p, f , ~] = fileparts(fp);
    imwrite(img, fullfile(p,[f '.png']));
    
end
