function out = processMinaData(inp, tffit)

if nargin < 1
    inp = uigetdir('D:\Data\');
    if isempty(inp)
        return
    end
end

if nargin < 2
    tffit = 1;
end
%mini2con opts. Only used if tffit
m2copts.frcfil = 10;

%Takes a folder structure thats like this:
% \Parent\Condition\abcd.mat
%And for each mat file, runs mini2con on it, then splitcondfiles

%Run-one-and-done, for testing eg XWLC fitting options


%Input: Parent folder, that contains folders for each separate trace
dd = dir(inp);

%Get folders
isf = [dd.isdir];
dd = dd(isf);
dd = dd(3:end); %Strip '.' and '..'
folnams = {dd.name};

%For each folder...
out = struct(); %Store data here
for i = 1:length(folnams)
    %Get mat files
    curdir = fullfile(inp, folnams{i});
    dd = dir(fullfile( curdir, '*.mat'));
    nams = {dd.name};
    %Run mini2con
    if tffit
        m2c = cellfun(@(x) mini2con(fullfile( curdir, x), m2copts), nams, 'Un', 0);
        drawnow
    end
    
    %Run splitcondfiles on the output
    curdir = fullfile(curdir, 'mini2con');
    dd = dir(fullfile( curdir, '*.mat'));
    nams = {dd.name};
    cellfun(@(x) splitcondfiles( fullfile( curdir, x) ), nams)
    
    %Gather lo and hi crops
    [lo, ~, ~, ~, loN] = getFCs(-1, fullfile(curdir, 'Split_low'));
    [hi, ~, ~, ~, hiN] = getFCs(-1, fullfile(curdir, 'Split_hi'));
    %Hmm there will be some bad traces, but this will take them anyway. No way to tell really?
    
    %Add to output struct
    fn = matlab.lang.makeUniqueStrings( matlab.lang.makeValidName(folnams{i}), fieldnames(out) ); %Instead of genvarname
%     fn = genvarname(folnams{i}, fieldnames(out));
    out.(fn).lo = lo;
    out.(fn).loN = loN;
    out.(fn).hi = hi;
    out.(fn).hiN = hiN;
    if tffit
        out.(fn).wlc = m2c; %Indirectly, get the number of traces from this, too
    end
end



