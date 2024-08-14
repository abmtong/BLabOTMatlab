function hp = ramaplot(inax)
%Plots ramachandran regions, to scatter (phi, psi) on later

if nargin < 1
    inax = gca;
end

rR = ramachandranRegions;
hp = zeros(1,numel(rR)); %Oh, you can store objects as doubles and get them with get(hp(i))
hold(inax, 'on');

for i = numel(rR):-1:1 
    % print only contours
     hp(i) = patch(inax, rR(i).Patch(1,:), rR(i).Patch(2,:),...
         rR(i).Color, 'EdgeColor', rR(i).Color,...
        'DisplayName', rR(i).Name, 'FaceColor', 'none');
end

xlim(inax, 181 * [-1 1])
ylim(inax, 181 * [-1 1])