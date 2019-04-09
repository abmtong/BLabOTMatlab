function s = stepup25k

%25k 5-step stepup

n5 = 235; %estimated number of 5* bases as of 040619, taken as n pages in below url
%from https://exvius.gamepedia.com/Category:Base_5%E2%98%85
%overestimate, as there are more pages than units (for unlreleased, alternate-language ones

n5b = 1; %number of 5 stars in this banner, assumedly you only want one of them

%gather 5* banner roll chances in a
a = [];

%step 1: 9+2
a = [a ones(1,9) ones(1,2) * 3.75];

%step 2: 9+2
a = [a ones(1,9) ones(1,2) * 3.75];

%step 3: 8+2+1
a = [a ones(1,8) ones(1,2) * 3.75 100/n5];

%step 4: 9+2
a = [a ones(1,9) ones(1,2) * 3.75];

%step 5: 8+2+1
a = [a ones(1,8) ones(1,2) * 3.75 100];

%xform pct to chance
a = a / 100 / n5b;

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

