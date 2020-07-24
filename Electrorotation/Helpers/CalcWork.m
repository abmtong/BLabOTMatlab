function [out, outraw] = CalcWork(inData, inProt, inOpts)

if nargin < 1
    [f, p] = uigetfile('*.mat');
    if ~p
        return
    end
    opts.path = p;
    inData = load(fullfile(p,f));
    inData = inData.eldata;
else
    opts.path = [];
end

%Outputs as a multiple of trap stiffness k, unless supplied
opts.k = 1;
opts.trimt = 1; %trim first cycle
opts.chambertilt = 0; %deg

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

%Get date, newer than 190829 = use new method, otherwise use old method
opts.isnewinf = str2double(inData.inf.Date) >= 20190829;

Fs = inData.inf.FramerateHz;

%Get rotation speed, dir
pinf = procparams(inData.inf);
rspd = pinf.rspd;
rdir = 2* isequal('Hydrolysis', pinf.dir) -1; %1 for hy, -1 for syn
nrot = Fs/rspd;
nrot = round(nrot); % This will mess up (slightly) speeds that unevenly divide 4000, but drift should be small? Can be fixed, but just avoid 3/7/9/etc. Hz

if opts.isnewinf
    rot = -inData.rotlong*2*pi;
    rot = rot - opts.chambertilt/180*pi;
else %negate prot, not rot
    rot = inData.rotlong * 2 * pi; %Convert to rads
    rot = rot + opts.chambertilt / 180 * pi; %adjust for tilt
end
%So this is measured with + = CCW, but RotTra does + = CW
% This is an offset to the trap position, but apply it to rot instead
% It should be TrapPos = TrapPos + tilt, but negate twice to apply to rot
len = length(rot);

if nargin < 1 || isempty(inProt)
    switch pinf.mode
        case 'Constant Speed'
            inProt = getprot_linear(1/pinf.rspd, 1e4);
            %interpolate to find actual trap positions. inProt is in t, theta(deg), so convert to rads
            trapp = interp1(inProt(:,1), inProt(:,2), mod(inData.time, 1/rspd ), 'previous')/ 180 * pi;
        case 'Designed'
            %Check if the protocol file is here
            pf = fullfile(opts.path, pinf.protfile);
            if ~exist(pf, 'file')
                %Else prompt the user
                [f, p] = uigetfile([p '*.mat'], 'Select protocol file');
                pf = fullfile(p,f);
            end
            tmp = load(pf);
            inProt = tmp.eldata.protfull;
            inProt = inProt(:, [1 3]);
            %interpolate to find actual trap positions. inProt is in t, theta(deg), so convert to rads
            trapp = interp1(inProt(:,1), inProt(:,2), mod(inData.time, 1/rspd ) * rspd, 'previous')/ 180 * pi;

        otherwise
            error('Invalid protocol/mode')
    end
end


%Fix sign difference between protocol and rotationtracker
% This is what it should be
% rot = -rot;
% if rdir == -1 % SO up until 8/29 ? 
%     trapp = mod(-trapp, 2*pi);
% %     rot = -rot;
% end
if opts.isnewinf
    if rdir == 1 %Negate dir if syn
        trapp = mod(-trapp, 2*pi);
    end
else
    if rdir ==1 %negate... if hy?
        trapp = mod(-trapp, 2*pi);
        %     rot = -rot;
    end
end

%W = F-bar * diff(theta)
dth = (diff(rot));
tdif = mod((rot - trapp) + pi/2, pi) - pi/2;
% fbar = (tdif(1:end-1) + tdif(2:end))/2;
fbar = 0.5*sin(2*(tdif(1:end-1) + tdif(2:end))/2);
W = dth .* fbar * opts.k;

%Reject some areas based on what side of the trap they're in
stT = 1:nrot:len;
stT = stT(2:end); %remove first revolution
hei = length(stT)-1;
phs = zeros(1,hei);
ws = zeros(1,hei);
rot1 = {};
rot0 = {};
for i = 1:hei
    %Gather work, rotation, protocol
    ws(i)= sum(W(stT(i):stT(i+1)-1));
    tmpr = rot(stT(i):stT(i+1)-1);
    tmpp = trapp(stT(i):stT(i+1)-1);
    %Shift so it starts between 0 and 2pi.
    tmpr = tmpr - floor( prctile(tmpr,25)/2/pi ) * 2 * pi;
    %Find out which side of trap it's closer to
    phase = mod(round( (tmpr - tmpp)/pi ), 2);
    if all(phase == 1) %All phase = 1, so this is off-phase
        %Adjust tmpp
        phs(i) = 1;
        rot1 = [rot1 tmpr]; %#ok<AGROW>
    elseif all(phase == 0) %All phase = 0, so in-phase
        phs(i) = 0;
        rot0 = [rot0 tmpr]; %#ok<AGROW>
    else %Mixture, reject
        phs(i) = -1;
%         ws(i) = NaN;
    end
end

t=(1:nrot)/Fs;

% midpt = nrot/2;
% tmpop = [tmpp(midpt+1:end)-pi tmpp(1:midpt)+pi];
% tmpop = tmpop - tmpop(1);
tmpop = tmpp;
%Average work per cycle

%If constant, average over all ok cycles
if isequal(pinf.mode, 'Constant Speed')
    pok = phs ~= -1;
    out.w = [mean(ws(pok)) std(ws(pok)) sum(pok)];
    rot1 = mean(reshape([rot1{:}], nrot, []),2)';
    rot0 = mean(reshape([rot0{:}], nrot, []),2)';
%     rot1 = mod(rot1, 2*pi);
%     rot0 = mod(rot0, 2*pi);
    figure; subplot(3,1,[1 2]),plot(t,tmpp),hold on, plot(t+t(end)/10,tmpop),  plot(t+t(end)/10,rot1-pi), plot(t,rot0)
    text(0,pi,sprintf('W = %0.4f +- %0.4f, N=%d', out.w))
    x = 1:length(ws);
    axis tight
    pez = phs == 0;
    peo = phs == 1;
    axs= subplot(3,1,3); hold on, scatter(x(pez), ws(pez), 'g'),
    scatter(x(peo), ws(peo), 'b*')
    pno = phs == -1;
    scatter(x(pno), ws( pno), 'r')
%     yl = [min(ws(pok)) max(ws(pok))];
%     drawnow
%     axs.YLim = yl;
%If optimal, split between in-phase and out-of-phase
elseif isequal(pinf.mode, 'Designed')
    pez = phs == 0;
    peo = phs == 1;
    out.w = [mean(ws (pez) ) std(ws(pez)) sum(pez)];
    out.wopp = [mean(ws (peo) ) std(ws(peo)) sum(peo)];
    %Average protocol snips
    rot1 = mean(reshape([rot1{:}], nrot, []),2)';
    rot0 = mean(reshape([rot0{:}], nrot, []),2)';
%     r1 = calcResid(t, rot1);
%     r0 = calcResid(t,rot0);
%     rot1 = mod(rot1, 2*pi);
%     rot0 = mod(rot0, 2*pi);
    figure; subplot(3,1,[1 2]), plot(t,tmpp),hold on, plot(t+t(end)/10,tmpop),  plot(t+t(end)/10,rot1-pi), plot(t,rot0)
    text(0,pi,sprintf('W = %0.4f +- %0.4f, N=%d', out.w))
    text(0,pi/2,sprintf('Wop=%0.4f +- %0.4f, N=%d', out.wopp))
    x = 1:length(ws);
    axis tight
    axs= subplot(3,1,3); hold on, scatter(x(pez), ws(pez), 'g'),
    scatter(x(peo), ws(peo), 'b*')
    pno = phs == -1;
    scatter(x(pno), ws( pno), 'r')
    axis tight
%     yl = [min(ws(~pno)) max(ws(~pno))+eps(100)];
%     drawnow
%     axs.YLim = yl;
end
outraw.ws = ws;
outraw.phs = phs;