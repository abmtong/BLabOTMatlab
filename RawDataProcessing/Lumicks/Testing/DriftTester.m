function DriftTester(infp)

if ~nargin
    [f, p] = uigetfile('*.h5', 'Mu', 'on');
%     [f, p] = uigetfile('*.h5');
    if iscell(f)
        cellfun(@(x) DriftTester(fullfile(p, x)), f)
        return
    end
    infp = fullfile(p,f);
end

%Read data
dat = readh5all(infp);

%Compare: Mirror extension vs. camera data
mirdat = dat.Trapposition_N1X*1000;
camdat = (dat.Beadposition_Bead2X.Value - dat.Beadposition_Bead1X.Value)*1000;

camhz = 1/median( double(diff( dat.Beadposition_Bead1X.Timestamp) )/1e9 );

%Resample time for mirror
ndsamp = floor(length(mirdat)/length(camdat));
mirlow = windowFilter(@mean, mirdat, [], ndsamp);
mirlow = mirlow(1:length(camdat));

% mirlow = mirdat( round( linspace(1, length(mirdat), length(camdat) ) ) );

[~, f, ~] = fileparts(infp);

% figure('Name', f, 'Color', ones(1,3))
% plot(mirlow-mirlow(end), camdat-camdat(end))
% hold on, plot(xlim, xlim)
% axis tight
% legend({'Data' '1:1'})
% 
% figure('Name', f, 'Color', ones(1,3))
% plot(mirlow-mirlow(end)- camdat'+camdat(end))
% hold on, plot(xlim, [0 0])
% axis tight
% legend({'Data' '1:1'})
% 


figure('Name', f, 'Color', ones(1,3))
xx = (1:length(camdat))*ndsamp/5^7;
plot(xx, mirlow - mirlow(end)), hold on
plot(xx, smooth(camdat, 30)' - camdat(end))
axis tight

xlabel Time(s)
ylabel Position(rel,nm)
legend({'Mirror' 'Camera'})
% pf = polyfit(mirlow(:), camdat(:), 1);
ax=gca;
ax.Children = ax.Children(end:-1:1); %Reverse draw order