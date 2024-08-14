function out = TxPull_XWLC(inst)

%Guess XWLC fitting on all data, take median

len = length(inst);
outraw = cell(1,len);
for i = 1:len
    %Get data
    xf = windowFilter(@mean, inst(i).ext, [], 100);
    ff = windowFilter(@mean, inst(i).frc, [], 100);
    
    %Crop pull, do this roughly
    [~, maxi] = max(ff);
    
    ft = fitForceExt(xf(1:maxi), ff(1:maxi));
    
    outraw{i} = ft;
end

out = reshape([outraw{:}], length(outraw{1}), [])';
out = [median(out, 1); out];