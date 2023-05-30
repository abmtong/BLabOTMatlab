function out = RP_passivep2(inst, inOpts)
%input: data + HMM fit from RP_passive

%Combine data: Needs to be combined. Let's scale (linear) from U to F
% Also need to eventually 

%Scale data to F=0, U=1 (subtract F, divide by U-F)
len = length(inst);
utps = cell(1,len);
ftps = cell(1,len);
for i = 1:len
    %Just scale the data we care about...
    scl = @(x) (x - inst(i).hmmfit.mu(1)) / (inst(i).hmmfit.mu(end) - inst(i).hmmfit.mu(1));
    utps{i} = cellfun(scl, inst.utps, 'Un', 0);
    ftps{i} = cellfun(scl, inst.ftps, 'Un', 0);
end
%And combine the data


%Plot U and F TPs. Hmm needs filtering?
[fhy, fhx] = nhistc([ftpx{:}], opts.binsz);
[uhy, uhx] = nhistc([utpx{:}], opts.binsz);

figure('Name', 'Un/folding Histograms')
plot(uhx, uhy), hold on, plot(fhx, fhy)
legend('Unfolding', 'Refolding')

%Bin by state
figure('Name', 'Hist by state')
hold on
for i = 1:length(mu)
    [~, xx, ~, yy] = nhistc( extF( vitfit == i ), opts.binsz);
    plot(xx,yy)
end
legend( [{'F'} arrayfun(@(x) sprintf('I%d',x), 1:opts.nint, 'Un', 0) {'U'}] )
