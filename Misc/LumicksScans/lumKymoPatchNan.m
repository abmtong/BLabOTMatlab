function out = lumKymoPatchNan(inx, maxgap)
%Patch NaNs with interp1
% Long enough gap is taken as no-data

if iscell(inx)
    out = cellfun(@(x) lumKymoPatchNan(x, maxgap), inx, 'Un', 0);
    out = [out{:}];
    return
end
%Get regions of NaN
[in, me] = tra2ind(isnan(inx));
dw = diff(in);

%Ignore edge NaN regions
for i = 2:length(me)-1 %Ignore starting/ending NaN regions
    %Do nothing for non-NaN regions
    if me(i) == false
        continue
    end
    
    %Do nothing for gaps longer than maxgap
    if dw(i) > maxgap
        continue
    end
    
    %interp1 the xdata from the surrounding points
    yq = interp1( [0 dw(i)+1],  [inx(in(i)-1) inx(in(i+1)) ] , 1:dw(i) );
    inx(in(i):in(i+1)-1) = yq;
end

%Split into contiguous non-NaN regions
[in, me] = tra2ind(isnan(inx));
out = cell(1,length(me));
for i = 1:length(me)
    if me(i) == 0
        out{i} = inx(in(i):in(i+1)-1);
    end
end

%Remove empty from out
out = out( ~cellfun(@isempty, out) );