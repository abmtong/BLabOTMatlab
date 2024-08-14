function out = ezFactBt(inst, pos)
%'Does the RNAP backtrack at this position?'

%key pauses at positions 28, 41, 
% translate to absolute position? or shift here?
%28 41 55 63

%Shift pos from Nuc start = 0 to Ruler start = 0
shift = 558-16+1; %Shift pos by this amount
pos = pos + shift;
fil = {200 100}; %Filter amount {half-width, downsample}
nplotshift = 20; %Shift amount between plots (sec)

nplotshift = 200; %Shift amount between plots (sec)
fil = {30 10};
% fil = {0 1};

dx = 3; %half-width of area to take as the pause
%Convert to region, if region isn't specified as input
if(length(pos)<2)
    pos = pos + [-dx dx];
end

len = length(inst);
rawout = cell(1,len);
for i = 1:len
    %Get pdd traces
    pdd = inst(i).pdd;
    indbt = inst(i).isbt;
    drA = inst(i).drA;
    
    %Skip empty
    ki = cellfun(@isempty, pdd);
    pdd = pdd(~ki);
    indbt = indbt(~ki);
    drA = drA(~ki);
    
    maxpdd = cellfun(@(x) x(end), pdd);
    
    %Find traces that reached this section
    tfreach = maxpdd >= (pos(1));
    
    %Find ones that reached but did not continue past
    tfstall = tfreach & maxpdd <= (pos(2));
    
    %Find ones that backtrack
    %bt is index of ind that is a backtrack, convert to mea
    [in, me] = cellfun(@tra2ind, pdd, 'Un', 0);
    bt = cellfun(@(x,y) x(y), me, indbt, 'Un', 0);
    %And check if any of these backtracked steps is near pos
    tfbt = cellfun(@(x) any( x >= (pos(1)) & x <= (pos(2)) ), bt);
    
    
    %And plot them...? Just get stats?
%     figure
    tmp = [tfreach(:) tfstall(:) tfbt(:)];
    rawout{i} = [length(maxpdd) sum(tmp,1),  sum(tfstall & tfbt)];
    
    figure('Name', sprintf('ezFactBt %d', i))
    %Plot the data around this area...?
    %Let's make separate axes for each condition (bypass, bypass+bt, stall no bt, stall+bt)
    axs = arrayfun(@(x) subplot2(gcf, [2 2], x), 1:4, 'Un', 0);
    cellfun(@(x,y) title(x, y), axs, {'Bypass' 'Bypass+Bt' 'Stall' 'Stall+Bt' });
    axs = [axs{:}];
    arrayfun(@(x)hold(x, 'on'), axs)
    
    
    
    hei = length(pdd);
    nplot = zeros(1, 4);
    
    for j = 1:hei
        %Check if reach == should plot
        if tfreach(j)
            %Check if bypass or stall, then if backtrack, to assign plot window
            iax = 1 + tfstall(j) * 2 + tfbt(j);
            
            %Get the time point of reaching pos(1) and reaching 0
            tpos = in{j}( find( me{j} >= pos(1) , 1, 'first' )+1);
            t0 = in{j}( find( me{j} >= 0 , 1, 'first' )+1);
            
            %Align drA and t0-space... somehow
            yy = drA{j};
            yf = windowFilter(@mean, yy, fil{:});
            ty0 = find(yf > 0, 1, 'first');
            
            %Plot with a shifted x-axis
            xx = ((1:length(drA{j})) - tpos - t0 - ty0 ) / 1e3 + nplot(iax) * nplotshift;
            plot(axs(iax), windowFilter(@mean, xx, fil{:}) , yf )
            
            
            nplot(iax) = nplot(iax)+1;
        end
    end
    %Add crossing line
    arrayfun(@(x) plot(x, xlim(x), mean(pos) * [1 1], 'k') , axs)
    %Set xlim
    arrayfun(@(x) axis(x, 'tight'), axs)
    arrayfun(@(x,y) xlim(x, [0 (y+1)*nplotshift]), axs, nplot)
    arrayfun(@(x) ylim( x, pos + [-20 20] ), axs)
    
end


out = reshape([rawout{:}], length(rawout{1}), [])';
% N, N_reach, N_stall, N_backtrack, N_stall+backtrack

%hmm... maybe just do this by hand.






