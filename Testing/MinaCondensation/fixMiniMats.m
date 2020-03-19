function fixMiniMats(p)
%Joins together #A #B #C mini .mat files, output in /comb
%Recursive

if nargin < 1
    p = uigetdir();
end
d = dir(p);

d = d(3:end); %Remove folders /. and /..

%Get file/folder names, dir names
dn = {d.name};
dt = [d.isdir];


%Recurse on folders, ignore 'comb' folder
cellfun(@(x) fixMiniMats(fullfile(p,x)),dn(dt & ~strcmp(dn, 'comb') ))

%Remove folders from list
dn = dn(~dt);

%Get .mat files
[~, ff, ee] = cellfun(@fileparts,dn, 'Un', 0);
ff = ff( strcmpi(ee, '.mat') );

outdir = fullfile(p, 'comb');

%Look for names with the pattern [str]A [str]B [str]C
done = false(1,length(ff));
while any(~done)
    n = ff{find(~done, 1, 'first')};
    %Look for similar names - same except for final letter
    grp = find(strncmp(ff, n(1:end-1), length(n)-1));
    stepdata = [];
    c = [];
    f = [];
    t = [];
    for i = 1:length(grp)
        fname = ff{grp(i)};
        stepdata = load(fullfile(p,[fname '.mat']));
        stepdata = stepdata.stepdata;
        tc = [stepdata.contour{:}];
        c = [c tc(:)']; %#ok<AGROW>
        tf = [stepdata.force{:}];
        f = [f tf(:)']; %#ok<AGROW>
        tt = [stepdata.time{:}];
        %Shift t if i > 1
        if i > 1
            tt = tt - tt(1) + t(end) + median(diff(t));
        end
        t = [t tt(:)']; %#ok<AGROW>
    end
    stepdata.contour = {c};
    stepdata.force = {f};
    stepdata.time = {t};
    if ~exist(outdir, 'dir') %Put here so we don't make the folder unless we need it
        mkdir(outdir);
    end
    save(fullfile(outdir,[n(1:end-1) '.mat']), 'stepdata')
    done(grp) = true;
end