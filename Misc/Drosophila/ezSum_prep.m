function out = ezSum_prep(dat, prc)

%Just plot as max(frame) over time, to get a sense of when spots appear?

%Instead of max, can take a percentile instead
if nargin < 2
    prc = 100; %If lowering, try like 99.99th + percentile. Maybe better as 'nth highest'
    % Since theres 256x512=.13Mpx, 99.99th is 13th highest px
end

thr = 0.2; %Threshold, scaled units
ch = 2; %Channel for detection
nup = 10; %At least this many frames above thr
nfrmax = 20; %Maximum frames. Or just use the same as nup?

nch = 2;
nfr = max( [dat.frame] );

out = zeros(nfr, nch);
len = length(dat);
for i = 1:len
    tmp = dat(i);
    out(tmp.frame, tmp.ch) = prctile( tmp.img(:), prc );
end 

%Scale to [0,1] for plotting
outscl = bsxfun(@minus, out, min(out, [], 1));
outscl = bsxfun(@rdivide, outscl, max(outscl, [], 1) );
figure, plot(outscl), legend({'Ch1' 'Ch2'})
hold on
plot( [1 nfr], [1 1] * thr )

%Extract channel
tmp = outscl(:,ch);

%Apply threshold
tf = [tmp(:)' > thr false]; %Pad a 0 at the end

%Look for upwards crossings that stay up for at least nup frames

%Basically, look for [0 ones(1,nup)] in tf
in = strfind(tf, [0 ones(1,nup)]) +1; %+1 to get the index of the first pt >thr

%For each ind, find next crossing
en = zeros(1,length(in));
out = cell(1,length(in));
for i = 1:length(in)
    %Find next crossing
    en(i) = find( (tf | (1:length(tf)) <= in(i) ) == 0, 1, 'first');
    
    %Cap en(i) as in(i) + nfrmax
    en(i) = min( en(i), in(i) + nfrmax );
    
    %Assemble frame [start, end, channel]
    out{i} = [in(i) en(i) ch];
    
    plot( [in(i) en(i)],[1 1]* thr/2, 'k')
end







