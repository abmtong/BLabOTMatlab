function table = Alex_ParseParams(Extension,Force,minFs,maxFs,LowerBound,UpperBound)

%vary min/max data plotting range to see how they vary the fit param.s
if nargin < 6
    UpperBound = [100 2000 6000 -1 -.1];
end
if nargin < 5
    LowerBound = [10 100 2000 -1 -.1];
end
if nargin < 4
    maxFs = 17:0.2:22;
end
if nargin < 3
    minFs = 0.2:0.2:5;
end

Extension = double(Extension);
Force = double(Force);
Guess     = UpperBound/2 + LowerBound/2;
Options    = optimset('TolFun',1e-10,'MaxIter',10000,'Display','off');

%preallocate
pL = zeros(length(minFs),length(maxFs));
sS = zeros(length(minFs),length(maxFs));
cL = zeros(length(minFs),length(maxFs));
rN = zeros(length(minFs),length(maxFs));

for i = 1:length(minFs)
    for j = 1:length(maxFs)
        IndStart = find(Force>minFs(i),1,'first');
        IndEnd   = find(Force<maxFs(j),1,'last');
    
        [a,res,~,~,~] = lsqcurvefit(@ForceExt_FunctionWLC,Guess,Force(IndStart:IndEnd),Extension(IndStart:IndEnd),LowerBound,UpperBound,Options);
        pL(i,j) = a(1);
        sS(i,j) = a(2);
        cL(i,j) = a(3);
        rN(i,j) = res;
    end
end

table.min = minFs;
table.max = maxFs;
table.pL = pL;
table.sS = sS;
table.cL = cL;
table.res = rN;

scrsz = get(groot,'ScreenSize');

f1 = figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2],'Name','Persistence Length (nm)','NumberTitle','off');
f2 = figure('Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2],'Name','Elastic Modulus (pN)','NumberTitle','off');
f3 = figure('Position',[1 1 scrsz(3)/2 scrsz(4)/2],'Name','Contour Length (nm)','NumberTitle','off');
f4 = figure('Position',[scrsz(3)/2 1 scrsz(3)/2 scrsz(4)/2],'Name','Residual','NumberTitle','off');

t1 = uitable(f1, 'Data',pL, 'ColumnName', table.max ,'RowName', table.min) ;
t2 = uitable(f2, 'Data',sS, 'ColumnName', table.max ,'RowName', table.min) ;
t3 = uitable(f3, 'Data',cL, 'ColumnName', table.max ,'RowName', table.min) ;
t4 = uitable(f4, 'Data',rN, 'ColumnName', table.max ,'RowName', table.min) ;

t1.Position(3) = t1.Extent(3);
t1.Position(4) = t1.Extent(4);
t2.Position(3) = t2.Extent(3);
t2.Position(4) = t2.Extent(4);
t3.Position(3) = t3.Extent(3);
t3.Position(4) = t3.Extent(4);
t4.Position(3) = t4.Extent(3);
t4.Position(4) = t4.Extent(4);

end