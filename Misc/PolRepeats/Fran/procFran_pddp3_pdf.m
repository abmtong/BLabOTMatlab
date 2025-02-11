function procFran_pddp3_pdf(inst, pdd2raw)
%Where do arrests + backtracks happen?

%Plot PDF of crossing time, arrest position, and backtrack positions
roi = [558 704]-16;
binsz = 5; %For PDF
%Plot colors
cols = lines(7);
cmod = @(x) mod(x-1, length(cols))+1; %1-indexed mod for colors

%Let's plot crossing time as regular, arrests as circle, backtracks as triangle?
ptyp = {  {'LineStyle' '-' 'Marker' 'none'} ... %Plot style for crossing time
    {'LineStyle' '--' 'Marker' 'o'}...   %for Arrests
    {'LineStyle' ':' 'Marker' '^'} }; %for Backtracks

figure('Name', 'procFran Backtrack Plot (pddp3)')
xlabel('Position (bp)')
ylabel('Residence Time (s)')
ax = gca;
hold(ax, 'on')

len = length(inst);
lgn = cell(3,len);
for i = 1:len
    yyaxis left
%     %Get crossing time histogram
    ki = inst(i).tfpick & inst(i).tfc;
    [snhy, snhx] = sumNucHist(inst(i).drA(ki), struct('Fs', 1e3, 'roi', roi, 'verbose', 0));
%     snhy = cumsum(snhy) / sum(snhy); %Convert from 'pdf' to 'cdf' and normalize
    snhx = snhx - roi(1);
    plot(snhx, snhy, 'Color', cols(cmod(i),:), ptyp{1}{:})
    
    yyaxis right
    %Get arrests: Find endpoints inside the ROI
%     arrs = cellfun(@(x) x(end), inst(i).pdd); %Use endpt
    arrs = cellfun(@(x) max(x), inst(i).pdd); %Use max progress
    arrs = arrs( arrs > roi(1) & arrs < roi(2) );
%     [x, y] = tocdf(arrs);
    
    %Scale weights inversely to how many traces are still alive, i.e. first arrest is 1/N, then 1/N-1, etc.
%     y = 1:length(y);
%     y = cumsum(y)/sum(y);
    arrs = sort(arrs, 'ascend');
%     wgt = 1./(length(arrs):-1:1);
    wgt = ones(1,length(arrs));
    [y, x] = nhistc(arrs, binsz, wgt);
    x = x-roi(1);
    plot(x, y, 'Color', cols(cmod(i), :), ptyp{2}{:})
    
    %Get backtracks
    bttmp = cell2mat(pdd2raw{i}(:));
    [y,x] = nhistc(bttmp(:,1), 5);
    %And plot
    plot(x, y, 'Color', cols(cmod(i), :), ptyp{3}{:})
    
    %Add to legend
    lgn(:,i) = cellfun(@(x) sprintf('%s: %s', inst(i).nam, x), {'RTH' 'Arrests' 'Backtracks'}, 'Un', 0);
end
%Need to swap around some legend entries due to yyaxis
lgn = lgn([1 4 2 3 5 6]);
legend(lgn(:))

