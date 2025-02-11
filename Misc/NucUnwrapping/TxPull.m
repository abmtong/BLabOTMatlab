function out = TxPull(inp)
%Plot F-X traces for the pulling a nucleosome after transcription experiment


fil = 100;

%2kb handles xloc (without the molecular ruler)
% xloc = ([-360 550 730] +360) *.34 + 400; %Nuc key locs [initial, entry, exit]], plus the base tether length

%4kb handles xloc (with the molecular ruler)
xloc = [1200 1468 1488 1520 1551]; %Nuc key locs, avg [stall, entry, dyad, end] extenstion @ 13pN for 4kb handles
% xloc = [0 0 1200 1468 1488 1520 1551]; %Nuc key locs, avg [stall, entry, dyad, end] extenstion @ 13pN for 4kb handles
  % These are obtained by [-NTP, abasic@entry, abasic@dyad, No Nuc] traces
  % Nuc is 146bp ~ 50nm, so entry-dyad should be ~25nm apart, end is a bit further
  %   ADD line at 1520, the current cutoff pt

S = 900; %Stretch modulus

fco = 13; %Force cutoff for length judgment


if nargin < 1
    inp = uigetdir();
    if ~inp
        return
    end
end

%Get the ForceExtension files
d = dir(fullfile(inp, 'ForceExtension*.mat'));
d = d(~[d.isdir]);
f = {d.name};
len = length(f);

figure Name plotTracesFX
ssz = get(0, 'ScreenSize');
ssz = ssz(3:4);
hold on
lens = nan(1,len);
outraw = cell(1,len);
for i = 1:len
    cd = load(fullfile(inp, f{i}));
    cd = cd.ContourData;
    xx = windowFilter(@mean, cd.extension, [], fil);
    yy = windowFilter(@mean, cd.force, [], fil);
    plot(xx,yy)
    
    ind = find(yy > fco, 1, 'first');
    if ind
        lens(i) = xx(ind);
    end
    
    
    outraw{i} = struct('name', f{i}(15:end-4), 'ext', cd.extension, 'frc', cd.force);
end
xlabel('Extension (nm)')
ylabel('Force (pN)')

%Add guidelines
for i = 1:length(xloc)
    frc = [0 60];
    plot( xloc(i) * [1 1] .* ( 1 + frc / S - 13/S ) , frc, 'k', 'LineWidth', 1 )
end

%Plot distance CCDF
ccx = sort(lens( ~isnan(lens) ));
ccy = (1:length(ccx))/length(ccx);
fg = figure('Name', 'CDF');
fg.Position = [ ssz/8 ssz*.75  ];
plot(ccx, ccy, 'o-')
hold on
%Add guidelines
for i = 1:length(xloc)
    plot( xloc(i) * [1 1] , [0 1], 'k', 'LineWidth', 1 )
end

xlabel('Tether Length (ish) (nm)')
ylabel('CDF')

xlim( xloc([2 end]) + 50 * [-1 1])
gi = ginput(1); %Choose crossing position

% %Sort by distance
% [~, si] = sort(lens);

out = outraw( lens > gi(1) );

out = [out{:}];









