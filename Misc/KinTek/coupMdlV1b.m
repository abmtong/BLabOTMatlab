function out = coupMdlV1b(t, data, sds, xg)
%Starting with minus coupling, as we'll need to expand to +C later
%b: Combine final state together

%Doing un-generalized functions because this is for a specific experiment. So no options in input

%Set up timepoints. Choose dt such that dt << min(diff(t)) (say, 10x smaller?), hopefully dt divides t
dt = 2;
tnmax = ceil(max(t)/dt)+1;
tki = round(t / dt) +1;

combineQR = 1;
normdat = 1;

if combineQR
    sds(:,4) = sqrt( sum(sds(:,4:5).^2 , 2));
    data(:,4) = data(:,4) + data(:,5);
    sds(:,5) = [];
    data(:,5) = [];
end


%Normalize input so total = 1 at each time?
if normdat
    sds = bsxfun(@rdivide, sds, sum(data, 2));
    data= bsxfun(@rdivide,data, sum(data, 2));
end

wgts = 1./sds; %Some sds are 0, so these will become inf. Replace with median value (?)
wgts( isinf(wgts) ) = median(wgts(:));


%Model is:
%{
I -> P -> Q -> R
     ||   
     E -> Q
%}
%Order reactants at I P E Q R
% Hmm since P=E is so fast, P>Q and E>Q is indistinguishable. Maybe if we set P>Q in +C and -C equal?

%Real data doesn't decay to zero, so must be some 'dead' state. Append reactants I_Dead, P_Dead, etc.

%All first-degree rates, with terms:
rxntype = 1;
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
    case 4 %Reversible death
        figtit = 'Minus C, P = E, Reversible Death';
    rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 2; 3 4; ... P > E, E > Q
        1 6; 2 7; 3 8; 4 9; 5 10; ... I > I_D, etc.
        6 1; 6 2; 8 3; 9 4; 10 5; ... %I_D > I, etc
        ];
        case 5 %Only death for I
        figtit = 'Plus C, P = E, Only I Dies';
    rxns = [1 2; 2 4; 4 5; ... I > P > Q > R
        2 3; 3 2; 3 4; ... P > E, E > Q
        1 6; 10 10; ... I > I_D, etc.
%         6 1; 6 2; 8 3; 9 4; 10 5; ... %I_D > I, etc
        ];
end
ns = max(rxns(:));
ltrs = 'IPEQRipeqr';

k0  = ones (1, size(rxns, 1)) * 1e-3; %Rates guess
klb = zeros(1, size(rxns, 1));
kub = ones (1, size(rxns, 1)) * 1;
x00 = median( sum( data, 2 ) ); %Initial conditions, all (= median row sum) at initial
xlb = 0;
xub = 1;

lb = [xlb klb];
ub = [xub kub];

%Override optimization for some k's here
tfopt = ones(size(lb)); %Whether to optimize certain k's or not
%Set certain values to zero
tfopt(3) = 0; %case 2, kP>Q

if ~all(tfopt) %Remind user if some rates have been fixed
    warning('Setting some rates as fixed')
end

if nargin < 4 
    xg = [x00 k0];
end

%Apply optimization constraints by setting lb and ub to guess
lb = lb .* tfopt + xg .* ~tfopt;
ub = ub .* tfopt + xg .* ~tfopt;

%Above can be put into kinNumIntV2 to get the output trace
tic
out = lsqnonlin(@minFunc, xg, lb, ub);
toc

%Plot
figure, hold on
%Real data, as errorbars; fit as lines
[~, ~, simraw] = minFunc(out);
simt = (0:tnmax-1) * dt;
sim = simraw(:, 1:ns/2) + simraw(:, (ns/2+1):ns);
if combineQR
    sim(:,4) = sim(:,4) + sim(:,5);
    ns = ns - 2;
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

if combineQR
    legend(obs, {'Initial' 'Pause 1' 'Error Site' 'Readthrough'})
else
    legend(obs, {'Initial' 'Pause 1' 'Error Site' 'Pause 2' 'Readthrough'})
end

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
    
    if combineQR %Combine Q and R pop.s
        sim(:, 4) = sim(:,4) + sim(:,5);
        sim(:,5) = [];
    end
    
    %Take least squares, weight by wgt
    scr = ( (sim - data) .* wgts );
    scr = scr(:);
end


end