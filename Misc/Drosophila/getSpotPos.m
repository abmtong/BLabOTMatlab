function out = getSpotPos(dat, apdv, mp)

%Input: outputs from fitRise, ezDroAP, ezDroMoviePos

%For each particle...

len = length(dat);

for i = 1:len
    %Get position (px) in movie img
    cen = fliplr( dat(i).cen );
    
    %Convert to embryo pixels: equals bottom-left pixel mp(1:2) plus position * scale factor mp(3)
    x = mp(1:2) + (cen-1) * mp(3);
    
    %Convert to APDV axis
    
    %If our pt. is X, then the projection onto AP is PX dot AP-hat over |AP|, or PX*AP/AP*AP
    % AP axis has A = 1
    px = x - apdv{2};
    pa = apdv{1} - apdv{2};
    a = dot(px,pa) / dot(pa,pa);
    
    vx = x - apdv{4};
    vd = apdv{3} - apdv{4};
    d = dot(vx,vd) / dot(vd,vd);
    
    dat(i).cenapdv = [a d];
end

out = dat;