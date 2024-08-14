function [out, outraw] = calcMesoE_simple(inst)
%Calculates free energy of the mesostrings given an REMD trajectory
% Same process as in Folding Short Peptides

%input: Cell of trajectory data with fields EPtot (energy from Amber), bb (backbone trace) and temp0 (replica temperature)
%   this input is a 1xn cell of 1xm structs

%Options
% nbin = 100; %Bins for Histogram method. Let's try 100?
ncrop = 1000; %Take last N frames

%Apply crop
inst = cellfun(@(x) x(end-ncrop+1:end) , inst, 'Un', 0);
% Concatenate inst so we can extract temperature trajectories
inst = [inst{:}];

%Convert mesostrings from double to char, if they're not
if isa(inst(1).bb, 'double');
    for i = 1:length(inst)
        %Convert 0/1/2 to a/b/c character (so add 97 and cast)
        inst(i).bb = char( inst(i).bb(2:end-1) + 97 );
    end
end


%Number of temperatures
tempdat = [inst.temp0];
temps = unique(tempdat);
len = length(temps);

%Construct isotherm trajectories
dat = cell(1,len);
for i = 1:len
    tmp = inst( temps(i) == tempdat );
    [~, si] = sort([ tmp.nstep ]);
    tmp = tmp(si);
    dat{i} = tmp;
end
%Double check that these look okay?

%And just bin these mesos
outraw = cell(1,len);
temps = cell(1,len);
for i = 1:len
    %Just count probabilities with unique
    [um, ~, uc] = unique( {dat{i}.bb} );
    
    hei = length(um);
    nn = nan(1, hei);
    for j = 1:hei
        nn(j) = sum( uc == j );
    end
    
    %And sort by prob
    [ns, si] = sort(nn, 'descend');
    
    ns = ns/sum(ns);
    um = um(si);
    
    outraw{i} = struct('meso', um, 'p', num2cell(ns));
    
    %Grab temp
    temps{i} = dat{i}(1).temp0;
end



%And assign output
out = struct('mesos', outraw, 'temp', temps);

%Ramachandran plot?
%Copy ramachandran plot, from @ramachandran
figure Name RamachandranPlot; 
ramaplot;

%Plot as colors?
hues = (1:len+1) / (len+1);

for i = 1:len
    %Get phis and psis. This is dat{i}(j).phipsi(:,1) for phi, (:,2) for psi
    %Transpose to concatenate. Strip first and last NaNs, and omegas?
    tmp = {dat{i}.phipsi};
    tmp = cellfun(@(x) x(2:end-1, 1:2)', tmp, 'Un', 0);
    tmp = [tmp{:}];
    
    phi = tmp(1,:);
    psi = tmp(2,:);
    plot(phi, psi, 'o', 'Color', hsv2rgb(hues(i), 1, .7));
end

%Set lims
xlim([-181 181])
ylim([-181 181])




