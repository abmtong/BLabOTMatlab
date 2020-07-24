function out = splitOE (input, numSplits)
%Splits input[] into its odd and even rows. Iterates numSplits times.
%If input is a row vector (first dimension length 1), returns it as a column vector
%Labeled as o and e, meaning the odd / even half. e.g. oee is odd/even/even: indexes ~ 7 mod 8

%Maybe I should have just done index ~ N mod 2^numSplits...

%Set defaults
if nargin < 2
    numSplits = 1;
end

%Detect if input is a row vector, then xform into col vector
sz = size(input);
if(sz(1) == 1)
    input = input';
end

out.input = input;

%Iterate over numSplits
for i = 1:numSplits
    %Each iteration adds 2^i new elements (e.g. o,e; oo,oe,eo,ee; etc.)
    for j = 1:2^i
        endname = '';
        r=j-1;
        %Generate the name of each of these elements
        %i is the length of the name, k iterates over the digits
        %Essentially we're calculating j in binary, then mapping 0 > o and 1 > e
        %e.g. i = 3, the name is 3 letters long. if j = 5, r = 4 = 010 (binary) -> oeo
        for k = i:-1:1
            d=2^(k-1);
            q = floor(r/d);
            r = rem(r,d);
            switch q
                case 0
                    endname = [endname 'o'];
                case 1
                    endname = [endname 'e'];
                otherwise
                    disp('error'); %debugging
            end
        end
        %Remove the last letter to find the starting array and split
        %e.g. oeo means the odd split of oe
        startname = endname(1:end-1);
        %For the first iteration, we're acting on the input.
        if isempty(startname)
            startname = 'input';
        end
        %Split, using q (from the above for loop) to choose whether to pick odd or even.
        out.(endname) = out.(startname)(q+1:2:end,:,:,:,:,:,:,:);
        %The multiple colons make this work for mulltidim. arrays up to the # of colons +1.
        %More dims req'd, add more colons.
    end
end
end