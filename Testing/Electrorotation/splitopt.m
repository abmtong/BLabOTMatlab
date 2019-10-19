function splitopt()

[f, p] = uigetfile('*.mat','MultiSelect','on');

if ~iscell(f)
    f = {f};
end

for i = 1:length(f)
    eld = load([p f{i}]);
    eld = eld.eldata;
    
    %check if it's designed
    
    if ~strcmp(eld.inf.Mode, 'Designed')
        continue
    end
    
    inf = procparams(eld.inf);
    rspd = inf.rspd;
    npts = eld.inf.FramerateHz / rspd;
    npts = round(npts); %This will cause issues if npts actually has to be rounded; see CalWork
    
    len = length(eld.time);
    chinds = (0:npts:len) + 1;
    hei = length(chinds)-1;
    %Make sure there's at least two cycles (one each)
    if hei < 2
        continue
    end
    times = cell(1,hei);
    xs = cell(1,hei);
    ys = cell(1,hei);
    rots = cell(1,hei);
    rotlongs = cell(1,hei);
    for j = 1:hei
        times{j} = eld.time(chinds(j):chinds(j+1)-1);
        xs{j} = eld.x(chinds(j):chinds(j+1)-1);
        ys{j} = eld.y(chinds(j):chinds(j+1)-1);
        rots{j} = eld.rot(chinds(j):chinds(j+1)-1);
        rotlongs{j} = eld.rotlong(chinds(j):chinds(j+1)-1);
    end
    
    %Save Designed runs(odd cycles)
    eldata = eld;
    eldata.time = [times{1:2:end}];
    eldata.x = [xs{1:2:end}];
    eldata.y = [ys{1:2:end}];
    eldata.rot = [rots{1:2:end}];
    eldata.rotlong = [rotlongs{1:2:end}];
    
    save([p f{i}(1:end-4) 'a.mat'], 'eldata');
    
    newParams = sprintf('%f V^2, %f Hz, %s', inf.v, inf.rspd, inf.dir);
    eldata.inf.Mode = 'Constant Speed';
    eldata.inf.Parameters = newParams;
    eldata.time = [times{2:2:end}];
    eldata.x = [xs{2:2:end}];
    eldata.y = [ys{2:2:end}];
    eldata.rot = [rots{2:2:end}];
    eldata.rotlong = [rotlongs{2:2:end}];
    
    save([p f{i}(1:end-4) 'b.mat'], 'eldata');
end