function out = coupMdlV1c(t, data, sds, datamc, sdsmc, xg)
%Starting with minus coupling, as we'll need to expand to +C later
%b: Combine final state together
%c: Handle +C by adding a fit parameter: amount coupled (

%Set up timepoints. Choose dt such that dt << min(diff(t)) (say, 10x smaller?), hopefully dt divides t
dt = 2;
tnmax = ceil(max(t)/dt)+1;
tki = round(t / dt) +1;

combineQR = 0; %Combine Q and R states
combineQRplot = 1; %Combine Q and R states to plot
normdat = 1;  %Normalize data to = 1 at each time

combineQRplot = combineQRplot || combineQR;

if combineQR
    sds(:,4) = sqrt( sum(sds(:,4:5).^2 , 2));
    data(:,4) = data(:,4) + data(:,5);
    sds(:,5) = [];
    data(:,5) = [];
    
    sdsmc(:,4) = sqrt( sum(sdsmc(:,4:5).^2 , 2));
    datamc(:,4) = datamc(:,4) + datamc(:,5);
    sdsmc(:,5) = []; %Will probably not propagate SD error... too much. Maybe between rounds?
    datamc(:,5) = [];
end


%Normalize input so total = 1 at each time?
if normdat
    sds = bsxfun(@rdivide, sds, sum(data, 2));
    data= bsxfun(@rdivide,data, sum(data, 2));
    
    sdsmc = bsxfun(@rdivide, sdsmc, sum(datamc, 2));
    datamc= bsxfun(@rdivide,datamc, sum(datamc, 2));
end

wgts = 1./sds; %Some sds are 0, so these will become inf. Replace with median value (?)
wgts( isinf(wgts) ) = median(wgts(:));


%Model is:
%{
I -> P -> Q -> R
     ||   
     E -> Q
%}
%Order reactants as I P E Q R
%Real data doesn't decay to zero, so must be some 'dead' state. Append reactants I_Dead, P_Dead, etc.

%All first-degree rates, with terms:
rxntype = 2;
switch rxntype
    case 1 %All forwards
        figtit = 'Plus C, All Forwards';
rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 4; ... P > E, E > Q
        1 6; 2 7; 3 8; 4 9; 5 10; ... I > I_D, etc.
        ];
    case 2 %E reversible
        figtit = 'Plus C, P = E';
    rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 2; 3 4; ... P > E, E > Q
        1 6; 2 7; 3 8; 4 9; 5 10; ... I > I_D, etc.
        ];
    case 3 %No death
        figtit = 'Plus C, No Death';
rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 4; ... P > E, E > Q
        10 10; ... I > I_D, etc.
        ];
    case 4 %Reversible death
        figtit = 'Plus C, P = E, Reversible Death';
    rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 2; 3 4; ... P > E, E > Q
        1 6; 2 7; 3 8; 4 9; 5 10; ... I > I_D, etc.
        6 1; 6 2; 8 3; 9 4; 10 5; ... %I_D > I, etc
        ];
    case 5 %Only death for I
        figtit = 'Plus C, P = E, Only I Dies';
    rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 2; 3 4; ... P > E, E > Q
        1 6; ... I > I_D, etc.
%         6 1; 6 2; 8 3; 9 4; 10 5; ... %I_D > I, etc
        ];
end
ns = max(rxns(:));
ltrs = 'IPEQRipeqr';

k0  = ones (1, size(rxns, 1)) * 1e-2; %Rates guess (naive)
klb = zeros(1, size(rxns, 1));
kub = ones (1, size(rxns, 1)) * 1;
x00 = median( sum( data, 2 ) ); %Initial conditions, all (= median row sum) at initial
xlb = [0 0];
xub = [1 1];
pctribo = 0.7; %Loading rate of the ribosome

if nargin < 6
    xg = [x00 pctribo k0];
end

%Above can be put into kinNumIntV2 to get the output trace
tic
out = lsqnonlin(@minFunc, xg, [xlb klb], [xub kub]);
toc

%Plot
figure, hold on
%Real data, as errorbars; fit as lines
[~, ~, simraw] = minFunc(out);
simt = (0:tnmax-1) * dt;
sim = simraw(:, 1:ns/2) + simraw(:, (ns/2+1):ns);
if combineQRplot
    sim(:,4) = sim(:,4) + sim(:,5);
    ns = ns - 2;
    if ~combineQR
        sds(:,4) = sqrt( sum(sds(:,4:5).^2 , 2));
        data(:,4) = data(:,4) + data(:,5);
        sds(:,5) = [];
        data(:,5) = [];
        
        sdsmc(:,4) = sqrt( sum(sdsmc(:,4:5).^2 , 2));
        datamc(:,4) = datamc(:,4) + datamc(:,5);
        sdsmc(:,5) = []; %Will probably not propagate SD error... too much. Maybe between rounds?
        datamc(:,5) = [];
    end
end
if isscalar(sds)
    sds = ones(size(data))*0.01;
end

obs = gobjects(1, ns/2);
for i = 1:ns/2
    col = colorcircle([i, ns/2+1], .7);
    col2 = colorcircle([i, ns/2+1], 0.5);
    obs(i) = errorbar(t, data(:,i), sds(:,i), 'LineStyle', 'none', 'Color', col, 'Marker', 'x');
    plot(simt, sim(:,i), 'Color', col)
    plot(simt, simraw(:,i), 'Color', col2)%Get a sense of how much is dead
end
title(figtit)
xlim([0 max(t)])
ylim([0 max(data(:))])
xlabel('Time (s)')
ylabel('Population (rel.)')

if combineQRplot
    legend(obs, {'Initial' 'Pause 1' 'Error Site' 'Readthrough'})
else
    legend(obs, {'Initial' 'Pause 1' 'Error Site' 'Pause 2' 'Readthrough'})
end

%Output to text
fprintf('%s_0: %0.8g\n', ltrs( 1 ), out(1))
fprintf('Loading Rate: %0.3f\n', out(2))
for i = 1:size(rxns, 1)
    fprintf('%s->%s: %0.8g\n', ltrs( rxns(i,1) ), ltrs( rxns(i,2) ), out(i+2))
end


%Make minimization function. Least squares, weighted by wghts ( = 1./SD)
function [scr, sim, simraw] = minFunc(ks)
% %HACK: kmtr death rates all the same
% ks(end-ns+1:end) = ks(end);
    
    %Optimization param ks =  [I_0, k1... k10]
    x0 = [ks(1), zeros(1, max(rxns(:))-1)];
    pctr = ks(2);
    %Create k matrix
    kmtr = zeros(max(rxns(:)));
    for ii = 1:size(rxns, 1)
        kmtr( rxns(ii,1), rxns(ii,2) ) = ks( ii + 2 );
    end
%     k.k1_1 = kmtr;


    
    %Simulate with kinNumInt
%     sim = kinNumIntV2(x0,k,1,tnmax);
    simraw = kinNumInt(x0,kmtr,[], 1,tnmax);
    
    %Take the timepoints
    sim = simraw(tki,:);
    
    %Combine I and I_D, etc.
    sim = sim(:, 1:ns/2) + sim(:, (ns/2+1):ns);
    
    if combineQR %Combine Q and R pop.s
        sim(:, 4) = sim(:,4) + sim(:,5);
        sim(:,5) = [];
    end
    
    
    %Take least squares, weight by wgt
    scr = ( (sim - (data - datamc * (1-pctr))/(pctr)  ) .* wgts );
    scr = scr(:);
end


end