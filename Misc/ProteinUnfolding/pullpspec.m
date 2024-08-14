function out = pullpspec(infp)

if nargin < 1
    [f, p ] = uigetfile('');
    if ~p
        return
    end
    infp = fullfile(p,f);
end


%Let's assume it's ContourData
cd = load(infp);
cd = cd.ContourData;

%Estimate trap sep
tsep = cd.extension - cd.forceAX / cd.cal.AX.k + cd.forceBX / cd.cal.BX.k;

%Filter down
tsep = windowFilter(@mean, tsep, 100, 1);


%Plot one F-Tsep and select region
fg = figure('Name', 'Select trap sep range');
tseplo = windowFilter(@mean, tsep, [], 1e3);
frclo = windowFilter(@mean, cd.force, [], 1e3);
plot(tseplo, frclo, 'o')
xlabel('Trap Sep')
ylabel('Force')
a = ginput(2);
delete(fg)

a = sort( a(1:2) );

%Grab sections of this trap sep
ki = tsep > a(1) & tsep < a(2);

fprintf('Kept %d of %d points\n', sum(ki), length(ki))

%Keep only large regions?

%Create start/end indicies
ind = diff([false ki false]);

st = find(ind == 1);
en = find(ind == -1);

len = length(st);
crp = cell(1,len);
for i = 1:len
    %Grab section
    tmp = cd.extension( st(i):en(i)-1 );
    
    %Apply minimum cutoff
    if length(tmp) < 100
        continue
    end
    
    %Lets zero each snippet
    tmp = tmp - mean(tmp);
    crp{i} = tmp;
    
%     %Or instead of zeroing by mean, zero by linear fit? moving average?
%     %Eh worse / not better
%     %Center x/y data
%     tmp = tmp - mean(tmp);
%     xx = (1:length(tmp))/length(tmp) - 0.5;
%     pf = polyfit(xx, tmp, 1);
%     off = polyval(pf, xx);
%     tmp = tmp - off;
%     crp{i} = tmp;

end

%Concatenate
out = [crp{:}];


%Pspec
calopts.Fmin = 1e3;
calopts.Fmax = 3e4;
calopts.Fs = 1e5;
calopts.nBin = 1e3;
calopts.lortype = 1;
figure('Name', 'pull_pspec')
calopts.ax = gca;

%Calc and plot cal
cal = Calibrate(out, calopts);



loglog(cal.F, cal.P)










