function plotSteps(indata)
len = length(indata);
indata = indata(:)'; %Make row vector

yy = reshape([indata; indata],1,[]); %y([ 1 1 2 2 3 3 4 4 ... len len ])
xx = [1 reshape([2:len;2:len],1,[]) len+1]; %[ 1 2 2 3 3 4 4 ... len len len+1 ]
%Alternatively, generate xx = [1 1 2 2 .... len len]; yy = y(xx); xx=circshift(xx,1); xx(end) = len+1;

plot(xx,yy)