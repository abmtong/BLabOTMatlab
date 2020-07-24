function modelCout()

% modelA(state, pos, outname)
state = [0 1 0 1 0 1 0 1];
pos =   [0 1 1 2 2 3 3 4] * .85;

n = length(state);
%filenames are c01, c02, ...
outname = cellfun(@(x)sprintf('c%02d',x), num2cell(1:n),'Uni', 0);

cellfun(@modelC, num2cell(state), num2cell(pos), outname)