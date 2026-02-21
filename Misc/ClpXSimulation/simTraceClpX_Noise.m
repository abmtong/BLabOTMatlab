function out = simTraceClpX_Noise(indat)

%KV options
fil = 10;
kvpf = single(2.5);

len = length(indat);

out = nan(1,len);
for i = 1:len
    %Filter
    y = indat{i};
    yf = windowFilter(@mean, y, [], fil);
    
    %Stepfind
    [ind, mea] = AFindStepsV4(yf, kvpf);
    
    %Pad-out ind back to full length
%     ind = [1 ind(2:end-1)*fil length(y)];
    tra = ind2tra(ind, mea);
    
    %Calculate noise
%     out(i) = std(y - tra);
    out(i) = std(yf-tra);
end





