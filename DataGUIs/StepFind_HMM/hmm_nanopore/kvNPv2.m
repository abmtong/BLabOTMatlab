function out = kvNPv2(dat, seq)

%Fit N steps to each staircase
%Then fitViterbi the state sequence against the other traces, search by net LLP
%  Need to set fitViterbi start and end 
%Prob set sig = 2 or so, not the acutal one [also avoids underflow, max d ~= 60, Z(30) = 1e-196

if ischar(seq)
    seq = seq2st(seq);
end

%Cut each in data to n steps ( n = length(seq) )

len = length(dat);
nst = length(seq);

trs = cell(1,len);
ins = cell(1,len);
mes = cell(1,len);
for i = 1:len
    [ins{i}, mes{i}, trs{i}] = AFindStepsV5(dat{i}, 0, nst-1, 0);
end

%Now fitVitterbiV2NP each
fvopts.sig = 2;
fvopts.trnsprb = 1e-2;
fvins = cell(len);
fvmes = cell(len);
fvtrs = cell(len);
fvscr = zeros(len);

pipe = '|';
fprintf( ['[' pipe(ones(1,len)) ']\n['] );
for i = 1:len
    fvopts.mu = mes{i};
    for j = 1:len
        fvtrs{i,j} = fitVitterbiV2NP(dat{j}, fvopts);
        [fvins{i,j}, fvmes{i,j}] = tra2ind(fvtrs{i});
        %Get relative logprb
        fvscr(i,j) = sum(log(normpdf(dat{j} - fvtrs{i,j}, 0, 2)));
    end
    fprintf('|')
end
fprintf(']\n')

out.me = mes;
out.scr = sum(fvscr, 2);
out.scrraw = fvscr;

