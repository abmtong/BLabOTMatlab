function modelCout2()
%renders model C, upside-down (was easier to code the DNA like this)
%here the part that gets scrunched moves upwards, too
%better visual, but not exactly the most accurate
%could instead do one DNA, typing in the A to B transition manually (i.e. sending @bDNA array arguments)

% modelA(state, pos, outname)
state = [0 1 0 1 0 1 0 1 0];
ang =   [0 0 1 1 2 2 3 3 4];

pos = ang * -.85;

n = length(state);
%filenames are c01, c02, ...
outname = cellfun(@(x)sprintf('cv2a%02d',x), num2cell(1:n),'Uni', 0);

cellfun(@modelCV2, num2cell(state), num2cell(pos), num2cell(ang), outname)