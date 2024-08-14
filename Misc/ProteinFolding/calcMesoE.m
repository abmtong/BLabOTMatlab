function [out, outraw] = calcMesoE(inst)
%Calculates free energy of the mesostrings given an REMD trajectory
% Same process as in Folding Short Peptides

%input: Cell of trajectory data with fields EPtot (energy from Amber), bb (backbone trace) and temp0 (replica temperature)
%   this input is a 1xn cell of 1xm structs

%Options
nbin = 100; %Bins for Histogram method. Let's try 100?
ncrop = 1000; %Take last N frames
tol = 1e-6; %Tolerance for iteratively calculating f
ttar = 300; %Target temperature for final calcs, K

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

%Bin energies into a histogram. Use same bins for all data
nrgs = cellfun(@(x) [x.EPtot], dat, 'Un', 0);
[~, ebins] = histcounts( [nrgs{:}], nbin);
%Bin energies of each trajectory
binnrg = cellfun(@(x) histcounts(x, ebins), nrgs, 'Un', 0);
E = (ebins(1:end-1) + ebins(2:end) )/2;
E = E(:);
dU = mean(diff(ebins));

%Create constants for easier math later
%Let's put E on dim 1, k on dim 2
NkE = reshape( [binnrg{:}], [], len ); %N^k_E , the count at a given temperature + energy
% Nk = ones(1,len) * ncrop; %N for each replica
Bk = 1./temps; %Temperature vector
BkE = bsxfun(@times, Bk, E);
% eBE = exp(BkE);

%Create estimate of free energy of the replicas as the median energy of each
fk = cellfun(@median, nrgs); %Should this like be times temperature?
fk = fk .* Bk;
% fk = -ones(1,len); %What if I give it a worse guess...

%Here we want to calculate the free energy of each replica. They use an iterative process,
% which involves guessing f, calculating weights, reestimating f, etc. until convergence
while true
    %The Methods in that Ho paper are bad/incorrect , using Eq 53 and 54 from Chodera, J Chem Theory Comput 2007, g_nk == 1 for all n, k
    % But keeping the namiing from Folding Short Peptides paper (Hm > NkE)
    
    %Calculate density of states Omega
    fmBE = bsxfun(@minus, fk, BkE);
    NeFmBE = ncrop * dU * exp( fmBE );
    om = sum(NkE, 2) ./ sum(NeFmBE, 2);
    
    %Calculate new fk
    fknew = -log( sum( dU* bsxfun(@times, om, exp(-BkE)), 1 ) );
    
    %Quit if fk changes less than some tolerance
    df = sum( abs(fk - fknew) );
    if  df < tol
        fk = fknew;
        break
    end
    
    %Check for divergence to Inf/nan
    if all(isnan(fk)) || all(isinf(fk))
        error('F NaN or Inf''d out, quitting')
    end
    
    fk = fknew;
end
% it converges! need to use the source paper for the method for the right equations

%Unique-ify mesostrings and discretize?
mesos = cellfun(@(x) {x.bb}, dat, 'Un', 0);
mesosall = [mesos{:}];
umeso = unique(mesosall);
nm = length(umeso);

%Calculate free energies of each mesostring

%Create some convenience variables
Fm = nan(1, nm);
Btar = 1/ttar;
eBtE = exp(Btar*E);
efBkE = exp( bsxfun(@minus, fk, BkE) );
%For each mesostring...

Hm = sum(NkE, 2);
for i = 1:nm
    %Recalc NkE histogram for this mesostring only
    tmp = cellfun(@(x,y) x( strcmp(y, umeso{i}) ), nrgs, mesos, 'Un', 0);
    NkxE = cellfun(@(x) histcounts(x, ebins), tmp, 'Un', 0);
    NkxE = reshape( [NkxE{:}], [], len );
    
%     %Calculate. Folding Short Peptides eqn 3 (though I should check this against the real paper..)
%         
%     top = sum( bsxfun(@times, NkxE, eBtE) , 2);
%     bot = sum( bsxfun(@times, NkxE, efBkE), 2);
%     
%       
%     Fm(i) = - 1/Btar * log( sum( top ./ bot , 'omitnan') );
    
    %Maybe a derivation from the Chodera paper?
    % Seems to be Eq 67, 68 of the other paper, with Akn = delta(n, n') exp(-BF) ; delta fcn picks mesostring n'
    
    efkBtE = exp( bsxfun(@minus, fk, Btar*E) );
    toptmp = bsxfun(@times, NkxE .* efkBtE, Hm .* om );
    top = sum(sum(toptmp));
    bot = sum( om .* exp(-Btar * E) );
    
    Fm(i) =-1/Btar * log(top/bot);
    
    
    %Something from Eq67, 68 with Akn = F(k,n)
end

%Calculate probability of each mesostring and sort by it and save
% Just weighted by free energy
Pm = exp(-Btar*Fm) / sum( exp(-Btar*Fm) );

%Create output sorted by Pm
[Pmsort, si] = sort(Pm, 'descend');
Fmsort = Fm(si);
umesosort = umeso(si);

out = struct('meso', umesosort, 'P', num2cell(Pmsort), 'FE', num2cell(Fmsort) );
%Also save some metadata for the results
outraw = struct('fk', fk, 'om', om, 'Ebin', E, 'NkE', NkE);

%They do some string combining, but ... let's figure that out later
% I guess take the top one and test swapping dashes for one spot and combining.



