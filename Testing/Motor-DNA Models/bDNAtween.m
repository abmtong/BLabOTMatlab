function outobjs = bDNAtween(ingob1, ingob2, nstep)
%just translates the orbs, does not warp them

%get pos-es pre and post
sz = size(ingob1);
xpre = cell(sz);
ypre = cell(sz);
zpre = cell(sz);
cpre = cell(sz);

xpos = cell(sz);
ypos = cell(sz);
zpos = cell(sz);
cpos = cell(sz);

for i = 1:prod(sz)
    xpre{i} = ingob1(i).XData;
    ypre{i} = ingob1(i).YData;
    zpre{i} = ingob1(i).ZData;
    cpre{i} = ingob1(i).CData;
    
    xpos{i} = ingob2(i).XData;
    ypos{i} = ingob2(i).YData;
    zpos{i} = ingob2(i).ZData;
    cpos{i} = ingob2(i).CData;
end

%move ingob1 orbs
for t = 0:nstep
    for i = 1:prod(sz);
        ingob1(i).XData = xpos{i}*(t/nstep) + xpre{i} * (nstep - t) / nstep;
        ingob1(i).YData = ypos{i}*(t/nstep) + ypre{i} * (nstep - t) / nstep;
        ingob1(i).ZData = zpos{i}*(t/nstep) + zpre{i} * (nstep - t) / nstep;
        ingob1(i).CData = cpos{i}*(t/nstep) + cpre{i} * (nstep - t) / nstep;
    end
    drawnow
%     pause(.01)
end