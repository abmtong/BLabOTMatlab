function out = TxPullV2p1(inst)
%Plot F-X traces for the pulling a nucleosome after transcription experiment
%V2: Use fitNuc instead. Group instead based on final contour length.
% inst = traces from getFirstPulls, fit with fitNuc, then checked with TxPullGUIV2
% i.e. a = getFirstPulls; a = fitNuc(a,[],0); TxPullGUIV2(a);
%Fit with fitNuc, then judge based on full fit contour length

% fil = 100;

%2kb handles xloc (without the molecular ruler)
% xloc = ([-360 550 730] +360) *.34 + 400; %Nuc key locs [initial, entry, exit]], plus the base tether length

%4kb handles xloc (with the molecular ruler)
% xloc = [1200 1468 1488 1520 1551]; %Nuc key locs, avg [stall, entry, dyad, end] extenstion @ 13pN for 4kb handles
xloc = [900 1030 1200]; %3kb new handles. [Rough lower limit, no nuc 601, rough upper limit]
% xloc = [1200 1468 1488 1520 1551] -40 ; %250705 Shifted by a bit? New stall loc ~ 1160 (40 earlier), shift them all

% xloc = [0 0 1200 1468 1488 1520 1551]; %Nuc key locs, avg [stall, entry, dyad, end] extenstion @ 13pN for 4kb handles
  % These are obtained by [-NTP, abasic@entry, abasic@dyad, No Nuc] traces
  % Nuc is 146bp ~ 50nm, so entry-dyad should be ~25nm apart, end is a bit further
  %   ADD line at 1520, the current cutoff pt
  
%Set minimum sizes for LF and HF to be detected
lfmin = 10;
hfmin = 10;
  
  
%Get XWLCs
xw = {inst.xwlc};

%Get LF size, HF size, total DNA CL
len = length(inst);
cmax = nan(1,len);
lf = nan(1,len);
hf = nan(1,len);
for i = 1:len
    tmp = xw{i};
    if isempty(tmp)
        inst(i).nucid = nan;
        continue
    end
    cmax(i) = tmp(3)+tmp(5);
    lf(i) = tmp(4);
    hf(i) = tmp(5)-tmp(4);
    
    %Let's assign nucid
    inst(i).nucid = 1 + 1*(lf(i)>lfmin) + 2 * (hf(i)>hfmin);
end

%Plot
figure, hold on
xx = sort(cmax);
yy = (1:length(xx))/length(xx);
plot(xx,yy)
[p, x] = kdf(cmax, 1, 5);
p = p/max(p); %Scale to [0,1]
plot(x,p)
axis tight

%Add guidelines
for i = 1:length(xloc)
    plot(xloc(i)*[1 1], [0 1], 'k')
end

xlim(xloc([1 end]) + [-50 50])

%Draw cutoff line
a=ginput(1);

%And crop data
ki = ~isnan(cmax) & cmax > a(1);

out = inst(ki);
TxPullV2_plot(out);





