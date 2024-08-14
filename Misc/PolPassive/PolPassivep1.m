function out = PolPassivep1(inp, inOpts)
%Grabs traces
%Wants a folder structure like:
%{
PassiveData\
            a Condition 1\traces.mat
            b Condition 2\traces.mat
%}
%inp = PassiveData folder

%Crop by force options
opts.fil = 10; %Filter the force, sure
opts.minf = 4; %Minimum force, pN. Chosen both to remove pre-restart wait + break
opts.trim = [10 10]; %Trim these many pts on both sides

%Convert to contour. Take extension since not all data has bp values
opts.xwlcparams = [50 900];

%Get folder
if nargin < 1 || isempty(inp)
    inp = uigetdir;
end

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


%Get every subfolder
d = dir(inp);
fol = {d([d.isdir]).name};
fols = fol(3:end); %Remove '.' and '..'
%Folders are named "prefix Name", e.g. 'c Nuc F', Name = comment, prefix is just sorting

%Storage
len = length(fols);
nams = cell(1,len);
datc = cell(1,len);
datf = cell(1,len);
for i = 1:length(fols)
    %Get data
    fn = fols{i};
    [~, d, f] = getFCs(-1, fullfile(inp, fn));
    %Extension, force
    
    %Crop by force
    hei = length(d);
    for j = 1:hei
        %Filter force first
        ffil = windowFilter(@median, f{j}, opts.fil, 1);
        
        %Find ... first above minf to last above minf.
        st = find(ffil>opts.minf, 1, 'first') + opts.trim(1);
        en = find(ffil>opts.minf, 1, 'last') - opts.trim(2);
        
        d{j} = d{j}(st:en);
        f{j} = f{j}(st:en);
    end
    %Convert to contour
    c = cellfun(@(x,y) x ./ XWLC(y, opts.xwlcparams(1), opts.xwlcparams(2)) / .34 , d, f, 'Un', 0);
    
    %Eh remove empty, if none were taken
    ki = ~cellfun(@isempty, d);
    c = c(ki);
    f = f(ki);
    
    %Strip first word from filename
    ind = find(fn == ' ', 1, 'first');
    
    %And save
    nams{i} = fn(ind+1:end);
    datc{i} = c;
    datf{i} = f;
end

%Create struct
out = struct('name', nams, 'con', datc, 'frc', datf);





