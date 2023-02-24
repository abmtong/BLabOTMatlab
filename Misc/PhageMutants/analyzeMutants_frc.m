function out = analyzeMutants_frc(inst)
%Force response using vdist_force

len = length(inst);

% %% Vel-Force
% out = cell(1,len);
% for i = 1:len
%     out{i} = vdist_force(inst(i).con, inst(i).frc, struct('verbose', 0, 'velmult', -1));
% %Vel, sd, n, fbin, pct paused, fit [0mean 0sd 0pct , vmean vsd vpct vnet]
% % out = [vs' vsd' fn' fbinx' pau' fitmat mvbin(:) mvbinsd(:)];
% end
% 
% %
% 
% %Color
% 
% %Plot vel-F curves together
% figure('Name', 'Force-Vel'), hold on
% for i = 1:len
%     plot(out{i}(:,4), out{i}(:,1), 'Color', inst(i).color)
% end
% legend( {inst.name} )
% 
% %Norm by PFV. Lets just hardcode into a field
% 
% figure('Name', 'Normalized Force-Vel'), hold on
% for i = 1:len
%     plot(out{i}(:,4), out{i}(:,1) / inst(i).pfv, 'Color', inst(i).color)
% end
% legend( {inst.name} )
% 
% %Hmm, its gotta be slips....

%% Slips

%Lets just call a slip a <10bp movement in opposite direction (1pt, after filtering)
dec = 250;
thr = 7.5;

nsl = zeros(1,len);
nsl2 = zeros(1,len);
nbp = zeros(1,len);
nt = zeros(1,len);
for i = 1:len
    %Filter down
    cf = cellfun(@(x)windowFilter(@median, x, [], dec), inst(i).con, 'Un', 0);
    %Take difference
    dcf = cellfun(@diff,cf, 'Un', 0);
    dcff = [dcf{:}];
    isslip = dcff > thr;
    %Count slips
    nsl(i) = sum(isslip);
    %Sum translocation
    nbp(i) = -sum( dcff(~isslip) );
    nt(i) = length(isslip);
    
    %Keep traces isolated
    isslip = cellfun(@(x) x > thr, dcf, 'Un', 0);
    %Get average slips per trace
    tmp1 = ( cellfun(@sum, isslip) );
    %Get average kb per trace
     tmp2 = -cellfun(@(x,y) sum(x(~y)), dcf, isslip);
     nsl2(i) = mean( tmp1 ./ tmp2);
    
end

out = [nsl; nbp; nt; nsl2];

%% Final force
%Use frc(end) as force
frcs = cell(1,len);
for i = 1:len
    frcs{i} = cellfun(@(x) x(end), inst(i).frc);
end

%Plot as kdf
figure Name MaxForce
hold on
for i = 1:len
    [y, x] = kdf(frcs{i}, 0.1, 3);
    plot(x,y, 'Color', inst(i).color, 'LineWidth', 1)
end
legend({inst.name})
xlabel('Force at Tether Break')
