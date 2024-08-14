function out = ezPlotEjection(infps)

if nargin < 1
    [f p ] = uigetfile('Mu', 'on');
    if ~p
        return
    end
    if ~iscell(f)
        f = {f};
    end
    
    infps = cellfun(@(x) fullfile(p, x), f, 'Un', 0);
end

%Assume first file is green

len = length(infps);
out = cell(1,len);
outt = cell(1,len);
for i = 1:len
    cd = load(infps{i});
    
    cd = cd.ContourData;
    
    if mod(i, 2)
%         out{i} = [nan double(cd.apd1) nan];
        
        %Find first nonzero to last nonzero value
        st = find( cd.apd1 , 1, 'first');
        en = find( cd.apd1 , 1, 'last');
        if isempty(st) || isempty(en)
            out{i} = [nan 0 nan];
        else
            out{i} = [nan double(cd.apd1(st:en)) nan];
        end
        
    else
        out{i} = [nan double(cd.force( 1 : end/2)) nan];
    end
    outt{i} = (1:length(out{i}))/ length(out{i}) + i;
end

%Separate grn and frc
%Filter for plotting
grn = out(1:2:end);
frc = out(2:2:end);

grnt = outt(1:2:end);
frct = outt(2:2:end);

grn = cellfun(@(x) windowFilter(@mean, x, 25, 1), grn, 'Un', 0);
frc = cellfun(@(x) windowFilter(@mean, x, 10, 1), frc, 'Un', 0);


% %Match Y-axis value:: make grn go up.
% maxf = max( cellfun( @max, frc) );
% maxg = max( cellfun(@max, grn) );
% grn = cellfun(@(x) x / maxg * maxf, grn, 'Un', 0);

% %Make arrays equal length, i.e. append empty frc if its not there
% frc = [frc repmat({[]}, 1, length(grn)-length(frc))];

% %Join together.
% tmp = [grn(:)'; frc(:)'];
% tmp = tmp(:)';
% out = [tmp{:}];

% %Create time axis. Make times equal-ish
% 
% outt = [outt{:}];

%Join grn and frc
grn = [grn{:}];
grnt = [grnt{:}];

frc = [frc{:}];
frct = [frct{:}];


figure, plot(frct, frc);
hold on
yyaxis right
plot(grnt, grn)



% grn = [out{1:2:end}];
% grn = double(grn);
% grn = windowFilter(@mean, grn, 25, 1);
% tt = (1:length(grn)) / 1e3; %Assumes 1kHz
% figure, plot(tt, grn)
% 
% frc = [out{2:2:end}];
% frc = double(frc);
% frc = windowFilter(@mean, frc, 10, 1);
% 
% tt = 1:length(
