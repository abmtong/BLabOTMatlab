function converrbar(in)

%Converts input data (columns) to errorbar (mean, sd)

mn = mean(in, 2);
sd = std(in, [], 2);


errorbar(mn, sd);



