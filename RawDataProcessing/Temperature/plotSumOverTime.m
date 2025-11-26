function out = plotSumOverTime(inp, dop)

%Use power over time

Fs = 25e3;
FsCal = 70e3;

if nargin < 1 || isempty(inp)
    inp = uigetdir;
end

if nargin < 2
    dop = DataOptsPopup();
end

%Get files
d = dir(inp);

%No folders
isp = [d.isdir];
d = d(~isp);

%Sort through d's...
len = length(d);
rawt = cell(1, len);
rawy = cell(1, len);
rawy2 = cell(1, len);
rawtc = cell(1, len);
rawkc = cell(1, len);
rawkc2 = cell(1, len);
rawcal = cell(1,len);
for i = 1:len
    %Starts with # and ends with .dat
    [~, f, e] = fileparts(d(i).name);
    if strcmpi(e, '.dat') && f(1) >= '0' && f(1) <= '9'
        %Load
        tmp = loadfile_wrapper( fullfile(inp, [f e]) , dop );
        
        %Get field
        sum = tmp.AS;
        sum2 = tmp.BS;
        
        %Downsample
        if length(sum) == 701400 %Bad check if this is a cal
            ds = FsCal;
%         elseif isfield(tmp, 'T')
%             %Get Fs from time vector
%             ds = 1/median(diff(tmp.T));
            cal = ACalibrateV2( fullfile(inp, [f e]) , handleOpts(dop, dop.cal) );
            rawtc{i} = d(i).datenum;
            rawkc{i} = cal.AX.k;
            rawkc2{i} = cal.BX.k;
            rawcal{i} = cal;
        else
            ds = Fs;
        end
        if length(sum) < ds %Skip offsets
            continue
        end
        sum = windowFilter(@mean, sum(:)', [], ds);
        sum2 = windowFilter(@mean, sum2(:)', [], ds);
        
        %Create time vector, dsamp'd Fs should be 1s
        tt = (1:length(sum));
        
        %Shift to date modified in datetime counts (number of days)
        
        %Shift tt(end) to 0 and change unit from s to days
        tt = (tt - tt(end)) / 24 / 3600 + d(i).datenum;
        
        %Save
        rawt{i} = tt;
        rawy{i} = sum;
        rawy2{i} = sum2;
    else
        continue
    end
end

%Concatenate
tall = [rawt{:}];
yall = [rawy{:}];
y2all = [rawy2{:}];

tcall = [rawtc{:}];
ycall = [rawkc{:}];
yc2all = [rawkc2{:}];

%Convert time to datenum
dall = datetime(tall, 'ConvertFrom', 'datenum');

figure, hold on
%Plot Sums
plot(dall, yall);
plot(dall, y2all);
xlabel('Time')
ylabel('Sum (V)')

%Plot k's on opposite axis
yyaxis('right')
plot(tcall, ycall, 'o');
plot(tcall, yc2all, 'o');
ylabel('Trap Stiffness (pN/nm) -- NOT corrected for temp.')

%Legend
legend({'ASum' 'BSum' 'kAX' 'kBX'})


out = [rawcal{:}];








