function out = makeMono(iny)
%Makes a trace monotonic, i.e. the nth point is the maximum of the 1-nth points

%If the subsequent point is lower, replace it with the subsequent point
for i = 2:length(iny)
    if iny(i) < iny(i-1)
        iny(i) = iny(i-1);
    end
end
out = iny;