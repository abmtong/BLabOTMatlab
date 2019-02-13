function out = getTraces(mx,s1,len)
%Gets traces of mx, starting at where s1 changes with length len (default: number of changes / length)

ch = findChanges(s1);

if(nargin < 3)
    len = floor(length(mx)/length(ch));
end

out = zeros(length(ch),len);

for i = 1:length(ch)-10
    out(i,:) = mx(ch(i):ch(i)+len-1);
end

end