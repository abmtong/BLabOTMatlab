function out = loadCroppedData(infp, cropstr)
%Load and crop data

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.mat');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

if nargin < 2 || isempty(cropstr)
    cropstr = '';
end

[p,f,e] = fileparts(infp);


tmp = load(infp);
if cropstr == -1
    out = tmp;
    return
end

crp = loadCrop(cropstr, p, [f e]);



%Crop based on fieldname
fn = fieldnames(tmp);
fn = fn{1};
tmp = tmp.(fn);
switch fn
    case 'stepdata'
        %Phage data, crop with cropstepdata
        out = cropstepdata(tmp, crp, 0);
        
    case 'ContourData'
        tki = tmp.time > crp(1) & tmp.time < crp(2);
        tmp.time = tmp.time(tki);
        tmp.time = tmp.time - min(tmp.time);
        fns = {'forceAX' 'forceBX' 'forceAY' 'extension' 'force'};
        for i = 1:length(fns)
            tmp.(fns{i}) = tmp.(fns{i})(tki);
        end
        out = tmp;
    otherwise
        %Try renametophage
        
        
        error('Unhandled data name for this function, %s', fn)
    
end