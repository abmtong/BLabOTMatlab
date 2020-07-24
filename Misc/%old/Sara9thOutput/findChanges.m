function changes = findChanges(x)
    curIndex = 1;
    for i = 2:length(x)
        if( x(i-1) ~= x(i) )
            changes(curIndex) = i; %dont know the end size, so unfortunately cant preallocate
            curIndex = curIndex + 1;
        end
    end

end