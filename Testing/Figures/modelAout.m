function modelAout()

% modelA(state, pos, ang, outname)
state = [0 1 0 1 0 1 0 1];
pos =   [0 1 1 2 2 3 3 4] * .85;
ang =   [1 1 2 2 3 3 4 4] *2*pi/5;

n = length(state);
%filenames are a01, a02, ...
outname = cellfun(@(x)sprintf('a%02d',x), num2cell(1:n),'Uni', 0);

cellfun(@modelA, num2cell(state), num2cell(pos), num2cell(ang), outname)

%take a top-view picture
% modelA;
% ax = gca;
% ax.CameraPosition = [0 0 10];
% ax.CameraUpVector = [1 0 0];
% print(gcf, 'topview', '-dpng', '-r192')
