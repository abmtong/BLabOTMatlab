function s = stepup12k

%12k 5-step stepup

n5 = 235; %estimated number of 5* bases as of 040619, taken as n pages in below url
%from https://exvius.gamepedia.com/Category:Base_5%E2%98%85
%overestimate, as there are more pages than units (for unlreleased, alternate-language ones

%gather 5* banner roll chances in a
a = [];

%step 1: 1 1.5x
a = [a 1.5];

%step 2: 2 1x
a = [a ones(1,2)];

%step 3: 4 2x
a = [a ones(1,4) * 2];

%step 4: 7
a = [a ones(1,7)];

%step 5: 9+1+1, 5x
a = [a ones(1,9)*5 3.75*5];
%xform pct to chance
a = a / 100;
%last +1 is a 5* guaranteed, so chance is 5/n5+4
a = [a 5/(n5+4)];

%simulate pulling n times
n=1e7;
out = zeros(1,n);
fprintf('[');
for i = 1:n
    out(i) = sum( a > rand(size(a)) );
    if mod(i,floor(n/10)) == 0
        fprintf('|');
    end
end
fprintf(']\n')

fprintf('Sanity Check: Chance for 0 5*s: %0.4f\n', prod(1-a))

%do stats
m = max(out)+1;
s = zeros(1,m);
for i = 1:m
    s(i) = sum(out == i-1)/n;
    fprintf('Chance for %d 5*s: %0.4f\n', i-1, s(i))
end

