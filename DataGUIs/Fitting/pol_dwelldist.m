function out = pol_dwelldist(dwstruct)

%For each struct in dwstruct...
%Started as AnalyzeAAP

%For each fieldname in dwstruct, do exp fitting and kn comparisons and save figs

%Because of artifacts(?) , short fitting is a bit wonk, leading to fitting of additional very fast decays.
% Maybe try limiting decay spds / further cropping short times
   % Handling now as : rates >>100, ignore; rates similar to the 'major' , add their populations (e.g. a 40/s, 20% + 20/s, 60% = 20/s, 80%)
   %
%If it's not a struct, make it one
if ~isstruct(dwstruct)
    tmp.a = dwstruct;
    dwstruct = tmp;
end
   
   
fn = fieldnames(dwstruct);
len = length(fn);
xrng = [2e-3 inf];
nmax = 10; %max exponentials to fit

out = cell(1,len);


for i = len:-1:1
    f = fn{i};
    dw = dwstruct.(f);
    
    
    %Fit separately
    [o, or] = cellfun(@(x) fitnexp_cfit(x( x > xrng(1) & x < xrng(2) ), nmax, 0), dw, 'Un', 0);

    %Fit together
    dwa = [dw{:}];
    [oa, ora] = fitnexp_cfit(dwa( dwa > xrng(1) & dwa < xrng(2) ), nmax);
    set(gcf, 'Name', f);
    
    %Save results in out
    res = [];
    res.fit = oa;
    res.fitraw = ora;
    res.sfit = o;
    res.sfitraw = or;
    res.name = f;
    out{i} = res;
end

