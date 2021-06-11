function out = minaSim(inModel)

dt = 0.001;
nT = round(5/dt);
len = 6000;

%Chance to act is per-site, i.e. for every open site, roll rand < dt*k
%Each has a footprint ftp and a extension change dx

%Define model parameters

%Core histone
mdl.his.k = 0.02;
mdl.his.ftp = 240;
mdl.his.dx = 160;
mdl.his.method = 2;

%H1
mdl.h1.dist = 200; %Minimum distance for H1 to link two adjacent histones
mdl.h1.k = .1; %Chance for that to occur

%Condensin
mdl.con.k = 0.001;
mdl.con.v = 50; %bp/s


if nargin >0 
    mdl = handleOpts(mdl, inModel);
end

out = zeros(1,nT);
out(1) = len;

histLoc = []; %Location of start of histone footprint
condLoc = zeros(0,3); %Location of condensin binding + current extent

%Animate?
ani = 50; %every N dt, set to 0 if no
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
    
    %Handle H1
    
    %Handle condensin
    [condLoc, condPos] = doCond(condLoc, mdl.con);
    dna = dna & ~condPos;
    
    %Calculate extension
     out(i) = sum(dna);
    
    %Animate?
    if ani && ~mod(i,ani)
        hclr = zeros(1,len) + histPos * 1;
        shst.CData = [hclr ; hclr];
        cclr = zeros(1,len) + condPos * 2;
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
    %curHist = array of nuc locations [ location, y/n H1'd ]
    kt = mdl.k * dt;
    
    chs = sort(curHist, 'descend');
    %Apply footprint of existing histones
    switch mdl.method
        case 1 % Has issues but 'looks nice' -- only allows wiggling in one dir
            locs = 1:len;
            for ii = chs
                locs(ii + (1:mdl.ftp) -1 ) = []; %Hmm this one looks nicer, allows for 'wiggling' but only in one dir
            end
            locs = locs(locs <= len - mdl.ftp + 1);
        case 2 %Maybe try to do it by allowing insertions in any region of bare DNA (i.e. exclusion is dx, not ftp)?
            loctf = true(1,len);
            for ii = [chs len+1]
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
    nh = [curHist locs(tf)];
    %Remove conflicting histones: for each pair too close, randomly remove one of them
    nhs = sort(nh);
    while true
        ind = find(diff(nhs) < mdl.ftp, 1, 'last');
        if isempty(ind)
            break
        end
        nhs(ind + randi(2) -1) = []; %Remove one of the histones
    end
    newHist = nhs;
    
    %Set histone locations
    histPos = false(1,len);
    for ii = newHist
        histPos(ii + (mdl.ftp - mdl.dx)/2 + (0:mdl.dx-1) ) = true;
    end
end

    function [newCond, condPos] = doCond(curCond, mdl)
        %curCond = nx2 array of position + amt DNA eaten
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
        addVel = sign(addFtp) * mdl.v * dt;
        
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
        
        %Set extent
        condPos = false(1,len);
        
        for ii = 1:size(newCond,1)
            nn = 1:len;
            ki = nn >= newexts(ii,1) & nn <= newexts(ii,2);
            condPos(ki) = true;
        end

    end

end
