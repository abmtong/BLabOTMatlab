function out = phagecolormap()

%Let the CLim be 0 to 1
%We need: Red (for laser)
%Gray (for bead)

%Let Red be 0 to 0.1, 100 entries

out = .95*ones(1001,3);% out(i,:) = entry for value (i-1)/1000, other colors black

lincol = linspace(0,1,101)';
lin0 = zeros(101,0);
lin1 = ones(101,1);

out(1:101, :) = [lin1 lincol.^.75 lincol.^.75];
out(end-100:end,:) = repmat(nicecolors(19), 101, 1);