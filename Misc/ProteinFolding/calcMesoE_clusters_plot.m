function out = calcMesoE_clusters_plot(inst)
%Summarize information from loadREMD_batch, which has several calcMesoE results

%Choose temperature
T = 300; %Choose temperature closest to this one

nfcrop = 1000; %Take last N frames. Do some manual checking for convergence?
convbin = 20; %Pts to bin for convergence checking

thr = 0.45; %Threshold for 'structured' peptide


%Get replica closest to target temperature
ts = [inst(1).mcluster.T];
[~, mini] = min( abs( ts-T ) );

len = length(inst);
outraw = cell(1,len);

%Create output plot array. Use a square
dims = ceil( sqrt( len ) ) * [1 1];
fg = figure('Name', 'Clusters Analysis');

%Prealloc
tfstruc = false(1,len); %Is this peptide structured?
peps = zeros(2,len); %Peptide coords

for i = 1:len
    %Get data for this replica
    tmp = inst(i).mcluster(mini);
    
    %Choose movie frames to use
    nfr = length(tmp.cnvt);
    fki = (-nfcrop+1:0) + nfr;
    %If crop range is larger than movie, just take it all
    if any(fki) < 1
        fki = 1:nfr;
    end
    
    %Get 
    dat = tmp.cnvt(fki);
    
    %Count 0s, 1s, 2s, ...
    maxc = max(dat);
    nn = histcounts(dat, (0:maxc+1)-0.5);
    
    %Crop mesostrings if some were cropped out
    meso = tmp.meso(1:length(nn));
    
    
    %Join mesostrings
    mesos = cellfun(@(x)x(2:end-1)+'a', meso, 'Un', 0);
%     cnum = num2cell(1:length(nn)); %To not join mesos, uncomment this and comment the line below
    [mesos, nn, cnum] = join_mesostrings(mesos, nn);
    
    
    
    %Re-sort
    [nn, si] = sort(nn, 'descend');
    mesos = mesos(si);
    cnum = cnum(si);
    
    %Make... stacked bar plot? for cluster pops. Stacked bar? Pie?
    
    %Create labels for pie
    nlab = length(mesos);
    labs = cell(1, nlab);
    for j = 1:nlab
        labs{j} = sprintf('c%s\n%s', sprintf('%d', cnum{j} ), mesos{j} );
    end
    
    %Crop to nonzero data
    imax = find(nn > 0, 1, 'last');
    
    %And plot
    ax = subplot2(fg, dims, i, .05);
    pie(ax, nn(1:imax), labs(1:imax));
    %Add text marker for everything
    text(0,-.5,inst(i).nam, 'Interpreter', 'none', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
    
    %Calculate whether a peptide is structured or not
    if nn(1)/sum(nn) > thr
        tfstruc(i) = true;
    end
    
    %Grab the peptide range from nam
    % Names are name_id_start-end, so find the last _ and the last -
    uscr = find(inst(i).nam == '_', 1, 'last');
    dsh = find(inst(i).nam == '-', 1, 'last');
    
    peps(i,1) = str2double( inst(i).nam (uscr+1:dsh-1) );
    peps(i,2) = str2double( inst(i).nam (dsh+1:end) );
    
    
end

%Set a (hopefully bright) colormap. HSV but stopping at purple
hsv9 = arrayfun(@(x) hsv2rgb([x, 1, 1]), linspace(0, 0.9 , 64), 'Un', 0 );
hsv9 = reshape([hsv9{:}], 3, [])';
colormap(hsv9)

%Process structuredness
pepstr = nan(len, max( peps(:) ));
for i= 1:len
    if tfstruc(i)
        pepstr(i, peps(i,1):peps(i,2)) = 1;
    else
        pepstr(i, peps(i,1):peps(i,2)) = 0;
    end
end
pepstr = mean(pepstr, 1, 'omitnan');

figure Name StructuredPlot, plot(pepstr)

%And create a string for chimera to plot struct > 0.5
tra = pepstr >= 0.5;
[in, me] = tra2ind(tra);
%Get regions where tra = true
ki = find(me == 1);
%Output these as atom selection from in(i) to in(i+1)-1 (e.g. '5-22,')
strs = arrayfun(@(x,y) sprintf('%d-%d,', x, y), in(ki), in(ki+1)-1, 'Un', 0);
%Concatenate
strs = [strs{:}];
%Strip final comma
strs = strs(1:end-1);
out = sprintf('color /*:%s red\n', strs);


