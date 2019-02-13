function out = modelabccmap()


%need these colors:

dnablue = nicecolors(12);
dnagrn = nicecolors(9);
dnapitch = nicecolors(5);

% motorpurple = nicecolors(13);
% motorpurple = mean([motorpurple; 1 1 1],1);

motorpurple = [170 168 254 ]/255;

motordrkpurp = nicecolors(14);

out = [dnablue; dnagrn; dnapitch; motorpurple; motordrkpurp];