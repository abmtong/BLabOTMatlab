function out = procwidnps(inseq)
%Processess text recognition of the widom NPS from the paper:
%{
New DNA Sequence Rules for High Affinity Binding to Histone Octamer and Sequence-directed Nucleosome Positioning
P.T. Lowary and J. Widom, JMB 1998
https://doi.org/10.1006/jmbi.1997.1494
%}

%inseq is a nx2 cell obtained by pdf > Fig 7 > OCR
% Not all are the full 100bp, so only take the full ones. Could instead pad with Ns but eh

len = size(inseq, 1);
out = cell(1, len);
for i = 1:len
    tmp = [inseq{i,1} inseq{i,2}];
    %Remove non-acgt, if OCR is bad
    tmp( ~( tmp == 'a' | tmp == 'g' | tmp == 'c' | tmp == 't') ) = [];
    out{i} = tmp;
end

%Remove ones without full coverage. These should be 100bp
lens = cellfun(@length, out);
out = out(lens == max(lens));

