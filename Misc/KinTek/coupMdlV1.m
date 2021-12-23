function out = coupMdlV1(t, data, sds)
%Starting with minus coupling, as we'll need to expand to +C later

%Normalize input so total = 1 at each time?
% sds = bsxfun(@rdivide, sds, sum(data, 2));
% data= bsxfun(@rdivide,data, sum(data, 2));

wgts = 1./sds; %Some sds are 0, so these will become inf. Replace with median value (?)
wgts( isinf(wgts) ) = median(wgts(:));

%Set up timepoints. Choose dt such that dt < min(diff(t)), hopefully dt divides t
dt = 1;
tnmax = ceil(max(t)/dt)+1;
tki = round(t / dt) +1;

%Model is:
%{
I -> P -> Q -> R
     ||   
     E -> Q
%}
%Order reactants at I P E Q R

%Real data doesn't decay to zero, so must be some 'dead' state. Append reactants I_Dead, P_Dead, etc.

%All first-degree rates, with terms:

rxntype = 2;
switch rxntype
    case 1 %All forwards
        figtit = 'Minus C, All Forwards';
rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 4; ... P > E, E > Q
        1 6; 2 7; 3 8; 4 9; 5 10; ... I > I_D, etc.
        ];
    case 2 %E reversible
        figtit = 'Minus C, P = E';
    rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 2; 3 4; ... P > E, E > Q
        1 6; 2 7; 3 8; 4 9; 5 10; ... I > I_D, etc.
        ];
    case 3 %No death
        figtit = 'Minus C, No Death';
rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 4; ... P > E, E > Q
        10 10; ... I > I_D, etc.
        ];
end
ns = max(rxns(:));
ltrs = 'IPEQRipeqr';

k0  = ones (1, size(rxns, 1)) * 1e-2; %Rates guess
klb = zeros(1, size(rxns, 1));
kub = ones (1, size(rxns, 1)) * 10;
x00 = median( sum( data, 2 ) ); %Initial conditions, all (= median row sum) at initial
xlb = 0;
xub = 1;

%Above can be put into kinNumIntV2 to get the output trace
tic
out = lsqnonlin(@minFunc, [x00 k0], [xlb klb], [xub kub]);
toc

%Plot
figure, hold on
%Real data, as errorbars; fit as lines
[~, ~, simraw] = minFunc(out);
simt = (0:tnmax-1) * dt;
sim = simraw(:, 1:ns/2) + simraw(:, (ns/2+1):ns);
if isscalar(sds)
    sds = ones(size(data))*0.01;
end
for i = 1:ns/2
    col = colorcircle([i, ns/2+1], .7);
    col2 = colorcircle([i, ns/2+1], 0.3);
    errorbar(t, data(:,i), sds(:,i), 'LineStyle', 'none', 'Color', col)
    plot(simt, sim(:,i), 'Color', col)
    plot(simt, simraw(:,i), 'Color', col2)%Get a sense of how much is dead
end
title(figtit)
xlim([0 max(t)])
ylim([0 max(data(:))])

%Output to text
fprintf('%s_0: %0.8g\n', ltrs( 1 ), out(1))
for i = 1:size(rxns, 1)
    fprintf('%s->%s: %0.8g\n', ltrs( rxns(i,1) ), ltrs( rxns(i,2) ), out(i+1))
end


%Make minimization function. Least squares, weighted by wghts ( = 1./SD)
function [scr, sim, simraw] = minFunc(ks)
% %HACK: kmtr death rates all the same
% ks(end-ns+1:end) = ks(end);
    
    %Optimization pararm ks =  [I_0, k1... k10]
    x0 = [ks(1), zeros(1, max(rxns(:))-1)];
    %Create k matrix
    kmtr = zeros(max(rxns(:)));
    for ii = 1:size(rxns, 1)
        kmtr( rxns(ii,1), rxns(ii,2) ) = ks( ii + 1 );
    end
%     k.k1_1 = kmtr;


    
    %Simulate with kinNumInt
%     sim = kinNumIntV2(x0,k,1,tnmax);
    simraw = kinNumInt(x0,kmtr,[], 1,tnmax);
    
    %Take the timepoints
    sim = simraw(tki,:);
    
    %Combine I and I_D, etc.
    sim = sim(:, 1:ns/2) + sim(:, (ns/2+1):ns);
    
    %Take least squares, weight by wgt
    scr = ( (sim - data) .* wgts );
    scr = scr(:);
end


end