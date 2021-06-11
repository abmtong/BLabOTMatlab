function out = minaSimV2(inModel)

mdl.ani = 50;
mdl.dt = 0.001;
mdl.maxT = 10;
len = 6000;

%Chance to act is per-site, i.e. for every open site, roll rand < dt*k
%Each has a footprint ftp and a extension change dx

%Define model parameters

%Core histone
mdl.his.k = 0.01;
mdl.his.ftp = 240;
mdl.his.dx = 160;
mdl.his.method = 3;
%H1
mdl.his.h1dist = 300; %Minimum distance for H1 to link two adjacent histones. Must be < 2 *his.ftp
mdl.his.h1k = .1; %Chance for that to occur

%Condensin
mdl.con.k = 0.001;
mdl.con.v = @()lognrnd(4.002,0.5316); %bp/s, Curtains experiment suggests a logn dist with [mu, sig] = [63,36] bp/s, = lognrnd(4.002,0.5316) 10.1126/science.aan6516 (Fig 3E), ~0.3pN (lambda genome stretched to 12um)
mdl.con.koff = log(2)/207.2; %/s, from same experiment/paper as ^, (half-survival probability is 10.3kb, at 16nm/s = 207.2s median survival time)
mdl.con.aniwid = 20; %bp, width of condensin to show as bright to mark the motor location

if nargin >0 
    mdl = handleOpts(mdl, inModel);
end

dt = mdl.dt;
nT = round(mdl.maxT/dt);

out = zeros(1,nT);
out(1) = len;

histLoc = zeros(0,2); %Location of start of histone footprint
condLoc = zeros(0,3); %Location of condensin binding + current extent

%Animate?
ani = mdl.ani; %every N dt, set to 0 if no0
if ani
    fg = figure('Color', [1 1 1]);
    %Different surfaces per component
    shst = surface([1:len; 1:len], [0*ones(1,len); ones(1,len)], zeros(2,len), zeros(2,len), 'EdgeColor', 'interp', 'LineWidth', 2);
    chst = surface([1:len; 1:len], [ones(1,len); 2*ones(1,len)], zeros(2,len), zeros(2,len), 'EdgeColor', 'interp', 'LineWidth', 2);
    xlim([0 len+1])
    xlabel('DNA Position (bp)')
    ylim([-0.5 2.5])
    set(gca, 'YTick', [0.5 1.5])
    set(gca, 'YTickLabel', {'Histones' 'Condensin'})
    set(gca, 'CLim', [0 4]) %0 = free, 1 = histone, 2 = condensin, etc.
    addframe('condani.gif', fg, .05, 1)
end

for i = 2:nT
    %Virtual DNA - true means contributes to extension
    dna = true(1,len);
    
    %Handle histones
    [histLoc, histPos] = doHist(histLoc, mdl.his);
    dna = dna & ~histPos;
    
    %Handle condensin
    [condLoc, condPos] = doCond(condLoc, mdl.con);
    dna = dna & ~condPos;
    
    %Calculate extension
     out(i) = sum(dna);
    
    %Animate?
    if ani && ~mod(i,ani)
        hclr = histPos;
        shst.CData = [hclr ; hclr];
        cclr = condPos;
        chst.CData = [cclr ; cclr];
        drawnow
        addframe('condani.gif', fg, .05, 1)
    end
    
end

if ani
    addframe('condani.gif', fg, 3, 1)
end

figure, plot( (1:nT)*dt, out)

function [newHist, histPos] = doHist(curHist, mdl)
    %curHist = array of nuc locations [ location, tf H1 ]
    kt = mdl.k * dt;
    kh1 = mdl.h1k * dt;
    [~, si] = sort(curHist(:,1), 'descend');
    chs = curHist(si,:);
    %Apply footprint of existing histones
    switch mdl.method
        case 1 % Has issues but 'looks nice' -- only allows wiggling in one dir
            locs = 1:len;
            for ii = chs(:,1)
                locs(ii + (1:mdl.ftp) -1 ) = []; %Hmm this one looks nicer, allows for 'wiggling' but only in one dir
            end
            locs = locs(locs <= len - mdl.ftp + 1);
        case 2 %Maybe try to do it by allowing insertions in any region of bare DNA (i.e. exclusion is dx, not ftp)?
            loctf = true(1,len);
            for ii = [chs(:,1)' len+1]
                stI = max(ii + (mdl.ftp-mdl.dx)/2 + 1, 1);
                enI = min(ii + (mdl.ftp+mdl.dx)/2 - 1, len);
                loctf(stI:enI) = false;
            end
            locs = find(loctf);
            locs = locs(locs <= len - mdl.ftp + 1);
        case 3 %Anarchy
            locs = 1:len-mdl.ftp + 1;
    end
    %Roll each of these locs if they add a histone
    tf = rand(size(locs)) < kt;
    nh = [curHist(:,1)' locs(tf)];
    ish1 = [curHist(:,2)' false(1, sum(tf))];
    %Remove conflicting histones: for each pair too close, randomly remove one of them
    [~, si] = sort(nh);
    nhs = [nh' ish1'];
    nhs = nhs(si,:);
    if isempty(nhs)
        nhs = zeros(0,2); %If empty, need it to be 0x2
    end
    while true
        ind = find(diff(nhs(:,1)) < mdl.ftp, 1, 'last');
        if isempty(ind)
            break
        end
        %Check if one is H1 -- if so, delete the other
        if nhs(ind,2)
            if nhs(ind+1,2), error('nooo'), end %SANITY
            nhs(ind+1, :) = [];
        elseif nhs(ind+1,2)
            if nhs(ind,2), error('nooo'), end %SANITY
            nhs(ind, :) = [];
        else
            nhs(ind + randi(2) -1, :) = []; %Remove one of the histones randomly
        end
    end
    newHist = nhs; %Should probably just rename nhs to newHist
    
    %Check for H1-ification
    %Sort for easier h1 checking
    [~, si] = sort(newHist(:,1), 'ascend');
    newHist = newHist(si,:);
    for ii = 1:size(newHist, 1)
        %Make sure this is not already H1'd
        if newHist(ii,2)
            continue
        end
        %Check to the left
        if ii ~= 1
            %Check if distance is close enough
            if newHist(ii) - newHist(ii-1) < mdl.h1dist
                %And roll for h1-ification
                if rand < kh1
                    newHist(ii-1:ii,2) = 1;
                end
            end
        end
        %Check to the right
        if ii ~= size(newHist,1)
            %Check if distance is close enough
            if newHist(ii+1) - newHist(ii) < mdl.h1dist
                %And roll for h1-ification
                if rand < kh1
                    newHist(ii:ii+1,2) = 1;
                end
            end
        end
    end
    
    %Set histone locations
    histPos = zeros(1,len);
    if isempty(newHist) %Bug? Since newHist is 0x2, for some reason for loops do a loop with ii = []. Check empty and override that here.
        return
    end
    for ii = newHist(:,1)'
        histPos(ii + (mdl.ftp - mdl.dx)/2 + (0:mdl.dx-1)) = 1;
    end
    df = diff(newHist(:,1));
    if isempty(df) %Similar bug(?) with empty 0x0 vs 0xn
        return
    end
    ish1 = newHist(1:end-1, 2) & newHist(2:end, 2);
    isok = find(df < mdl.h1dist & ish1);
    if isempty(isok) %Similar bug(?) with empty 0x0 vs 0xn
        return
    end
    for ii = isok'
        histPos(((1:len) > newHist(ii,1)+(mdl.ftp - mdl.dx)/2) & ((1:len) < newHist(ii+1,1)+(mdl.ftp - mdl.dx)/2) & (histPos == 0)) = 2;
    end
end

    function [newCond, condPos] = doCond(curCond, mdl)
        %curCond = nx3 array of [position , amt DNA eaten , vel]
        %Bind new condensins
        kt = mdl.k * dt;
        addCond = find(rand(1,len) < kt);
        
        %If it falls within a curCond, add it but set its velocity to zero
        curexts = sort(cumsum(curCond(:,1:2), 2), 2);
        ki = true(size(addCond));
        for ii = 1:length(ki)
            nc = addCond(ii);
            ki(ii) = ~any( arrayfun(@(x,y) nc >= x && nc <= y, curexts(:,1), curexts(:,2)) );
        end
        addCond = addCond(ki);
        addFtp = sign(randn(size(addCond))); %Initial footprint, lets say +-1
        addVel = sign(addFtp) * mdl.v() * dt;
        
        newCond = [curCond; [addCond(:) addFtp(:) addVel(:)]];
        
        %Translocate
        newCond(:,2) = newCond(:,2) + newCond(:,3);
        
        %Check if any new heads are inside another's bdy, if so, halt
        newexts = sort(cumsum(newCond(:,1:2), 2), 2);
        heads = newCond(:,1) + newCond(:,2);
        for ii = 1:length(heads)
            allbut = true(1,length(heads));
            allbut(ii) = false;
            xlo = newexts(allbut, 1);
            xhi = newexts(allbut, 2);
            newCond(ii,3) = newCond(ii,3) * ~any( arrayfun(@(x,y) heads(ii) >= x && heads(ii) <= y, xlo, xhi) );
        end
        
        %Unbinding
        unbind = rand(1,size(newCond,1)) < mdl.koff * dt;
        newCond = newCond(~unbind, :);
        
        %Set condensin locations and extent of translocated DNA
        condPos = zeros(1,len);
        plotexts = sort(cumsum([newCond(:,1) sign(newCond(:,2)) .* min(abs(newCond(:,2)),mdl.aniwid) newCond(:,2)], 2), 2);
        plotdir = sign(newCond(:,2));
        for ii = 1:size(newCond,1)
            nn = 1:len;
            if plotdir(ii) == 1
                ki = nn >= plotexts(ii,1) & nn <= plotexts(ii,2);
                condPos(ki) = 2;
                ki = nn >= plotexts(ii,2) & nn <= plotexts(ii,3);
                condPos(ki) = 1;
            else %plotdir == -1
                ki = nn >= plotexts(ii,1) & nn <= plotexts(ii,2);
                condPos(ki) = 1;
                ki = nn >= plotexts(ii,2) & nn <= plotexts(ii,3);
                condPos(ki) = 2;
            end
            
        end
        
    end

end
