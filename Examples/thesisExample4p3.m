function thesisExample4p3
%Code that generates Figure 4.3 Pairwise Distribution

%Generate an example ensemble of low-force p29 traces.
Fs=2500;
ntr = 10;
simtraceopts.Fs = Fs;
tr = arrayfun(@(x) simp29trace(3, simtraceopts), 1:ntr, 'Un', 0);




