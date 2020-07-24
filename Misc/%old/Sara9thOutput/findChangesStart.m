function changes = findChangesStart(x)
%Function turns to 10 at a pause, 5 afterwards, so we want when it turns 10 to 5
    curIndex = 1;
    for i = 2:length(x)
        if( x(i-1) > x(i) )
            changes(curIndex) = i; %dont know the end size, so unfortunately cant preallocate
            curIndex = curIndex + 1;
        end
    end
end