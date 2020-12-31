function [RLegs,ULegs] = CK_FindRampCycles_AT(infp)%t,x,fS,Boundaries)

%% Divide data into cycles
% plot x vs. t
%close all;
% figure('Units','normalized','Position',[0.0 0.3 1.0 0.7]);
% hold on;
% plot(t,x,'-b')

%Edited to work with my tools - Alex
%Instead do filepicker, grab fS from metadata, Boundaries from cropdata
if nargin < 1
    [file, path] = uigetfile('*.mat', 'Mu', 'on');
    if ~path
        return
    end
    %If file is cell, recurse
    if iscell(file)
        [RLegs, ULegs] = cellfun(@(x)CK_FindRampCycles_AT(fullfile(path, x)), file, 'Un', 0);
        return
    else
        infp = fullfile(path, file);
    end
end

%Load file
dat = load(infp);
%Get data and Fs, differing whether f-d vs. contour
fn = fieldnames(dat);
switch fn{1}
    case 'stepdata'
        t = dat.stepdata.time{1};
        x = dat.stepdata.force{1};
        if length(stepdata.time) > 1
            warning('Does not handle semipassive, only taking first cycle')
        end
        fS = stepdata.opts.Fs;
    case 'ContourData'
        t = dat.ContourData.time;
        x = dat.ContourData.force;
        fS = dat.ContourData.opts.Fs;
end

%Load crop-- the units for crop in this script is indicies, while it is time for mine. Convert.
[p, f, e] = fileparts(infp);
crp = loadCrop('', p, [f e]);
if isempty(crp)
    s = 1;
    e = length(t);
else
    s = max(1,round(crp(1)*fS));
    e = min(round(crp(2)*fS),length(t));
end

% % get input to define boundaries (start (s) and end (e))
% if nargin<4
%     idx = ginput(2);
%     [~,s] = min(abs(t - idx(1,1)));
%     [~,e] = min(abs(t - idx(2,1)));
% 
%     % % refine positions
%     % % filter data
%     % f_wnd = 10;
%     % xf = filtfilt(ones(f_wnd,1)/f_wnd,1,x);
% 
%     % beginning
%     wnd = 2*fS;
% 
%     idx1 = s-wnd;
%     if idx1<1
%         idx1 = 1;
%     end
% 
%     idx2 = s+wnd;
%     if idx2>numel(x)
%         idx2 = numel(x);
%     end
% 
%     % determine whether click is in a minimum or a maximum
%     if x(idx1)<x(s) || x(idx2)<x(s)
%         % maximum
%         [junk,s] = max(x(idx1:idx2));
%     else
%         % minimum
%         [junk,s] = min(x(idx1:idx2));
%     end
%     s = s + idx1;
% 
% 
%     % end
%     idx1 = e-wnd;
%     if idx1<1
%         idx1 = 1;
%     end
% 
%     idx2 = e+wnd;
%     if idx2>numel(x)
%         idx2 = numel(x);
%     end
% 
%     % determine whether click is in a minimum or a maximum
%     if x(idx1)<x(e) || x(idx2)<x(e)
%         % maximum
%         [junk,e] = max(x(idx1:idx2));
%     else
%         % minimum
%         [junk,e] = min(x(idx1:idx2));
%     end
%     e = e + idx1;
% else
%     s = Boundaries(1);
%     e = Boundaries(2);
% end

% crop data; store complete trace
x_full = x;
x = x(s:e);

% divide into cycles
m = mean(x);
% filter data
wnd = 100;
xf  = filtfilt(ones(wnd,1)/wnd,1,x);

S = zeros(numel(xf),1);
S(xf<m) = 1;
D = diff([0;S;0]);
D1 = find(D == 1);
D2 = find(D ==-1)-1;

% remove points close to the end
% D1(D1<wnd|D1>numel(x)-wnd)=[];
% D2(D2<wnd|D2>numel(x)-wnd)=[];
% I don't know why this is necessary and it was giving an error. Commented
% out on 170516- Lisa

%%
if D1(1) < D2(1)
    % trace begins with refolding limb
    if numel(D1)>numel(D2)
        % trace ends with refolding limb
        RLegs = zeros(numel(D1),2);
        RLegs(1,1)   = 1;
        RLegs(end,2) = numel(x);
        for i = 1:numel(D1)-1
            [~,RLegs(i,2)]   = min(x(D1(i):D2(i)));
            RLegs(i,2)   = RLegs(i,2)   + D1(i);

            [~,RLegs(i+1,1)] = max(x(D2(i):D1(i+1)));
            RLegs(i+1,1) = RLegs(i+1,1) + D2(i);
        end
        ULegs = [RLegs(1:end-1,2), RLegs(2:end,1)];        
    else
        % trace ends with unfolding limb
        RLegs = zeros(numel(D1),2);
        RLegs(1,1)   = 1;
        for i = 1:numel(D1)
            [~,RLegs(i,2)] = min(x(D1(i):D2(i)));
            RLegs(i,2)     = RLegs(i,2) + D1(i);
        end
        for i = 2:numel(D1)
            [~,RLegs(i,1)] = max(x(D2(i-1):D1(i)));
            RLegs(i,1)     = RLegs(i,1) + D2(i-1);
        end
        ULegs = [RLegs(2:end,1);numel(x)];
        ULegs = [RLegs(:,2), ULegs];
    end
else
    % trace begins with unfolding limb
    if numel(D2)>numel(D1)
        % trace ends with unfolding limb
        ULegs = zeros(numel(D2),2);
        ULegs(1,1)   = 1;
        ULegs(end,2) = numel(x);
        for i=1:numel(D2)-1
            [junk,ULegs(i+1,1)] = min(x(D1(i):D2(i+1)));
            ULegs(i+1,1)     = ULegs(i+1,1) + D1(i);

            [junk,ULegs(i,2)]   = max(x(D2(i):D1(i)));
            ULegs(i,2)       = ULegs(i,2) + D2(i);
        end
        RLegs = [ULegs(1:end-1,2), ULegs(2:end,1)];
    else
        % trace ends with refolding limb
        ULegs = zeros(numel(D2),2);
        ULegs(1,1) = 1;
        for i = 1:numel(D2)
            [junk,ULegs(i,2)] = max(x(D2(i):D1(i)));
            ULegs(i,2)     = ULegs(i,2) + D2(i);
        end
        for i = 2:numel(D2)
            [junk,ULegs(i,1)] = min(x(D1(i-1):D2(i)));
            ULegs(i,1)     = ULegs(i,1) + D1(i-1);
        end
        RLegs = [ULegs(2:end,1); numel(x)];
        RLegs = [ULegs(:,2), RLegs];
    end
end

RLegs = RLegs + s;
ULegs = ULegs + s;
%%
x = x_full;

% for i = 1:size(RLegs,1)
%     plot(t(RLegs(i,1):RLegs(i,2)),x(RLegs(i,1):RLegs(i,2)),'.r','MarkerSize',10);
% end
% 
% for i = 1:size(ULegs,1)
%     plot(t(ULegs(i,1):ULegs(i,2)),x(ULegs(i,1):ULegs(i,2)),'.g','MarkerSize',10);
% end
% set(gca,'Color','k');
