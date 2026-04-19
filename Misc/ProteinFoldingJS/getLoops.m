function out = getLoops(cc)
%Get loops from this CC
%Output rows = loop [start, end, length]

%Use tra2ind I guess?
[in, me] = tra2ind( double(cc) );

%Discard edges, regardless if they're 1 or 0
me = me(2:end-1);
in = in(2:end-1);

%Remaining 0's are loops, then
ki = find( me == 0 );
len = length(ki);
out = zeros(len,2);
for i = 1:len
    out(i,:) = in( ki(i) + [0 1] ) + [0 -1];
end

%Add loop length
if ~isempty(out)
    out = [out (out(:,2) - out(:,1) + 1) ];
end

%Add entropy term? Or put that in another function?