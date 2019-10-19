function s = stepup25k_elena

%24k 5-step stepup

% % if true, then they're doing the 4 ticket thing where you do stepup 1 again to get a special summon
% has30pct = 1;

n5 = 1/.0083; %estimated number of 5* bases, 1/pull rate

n5b = 1; %number of 5 stars in this banner, assumedly you only want one of them

%gather 5* banner roll chances in a
a = [];

%step 1: 9+2
a = [a ones(1,9) ones(1,2) * 3.75];

%step 2: 8+2+1
a = [a ones(1,8) ones(1,2) * 3.75 100/n5];

% %step 3: 8+2+1
% a = [a ones(1,8) ones(1,2) * 3.75 100/n5];

%step 4: 9+2
a = [a ones(1,9) ones(1,2) * 3.75];

%step 5: 8+2+1
a = [a ones(1,8) ones(1,2) * 3.75 100];

% %step 6, which is step 1 again with a 30% feat roll
% if has30pct
%     a = [a ones(1,9) ones(1,2) * 3.75 100/33];
% end

%xform pct to chance
a = a / 100 / n5b;

%simulate pulling n times
n=1e5;
out = zeros(1,n);
fprintf('[');
for i = 1:n
    out(i) = sum( a > rand(size(a)) );
    if mod(i,floor(n/10)) == 0
        fprintf('|');
    end
end
fprintf(']\n')

fprintf('Sanity Check: Expected 5*s: %d + %0.4f\n', sum(a==1), prod(1-a(a~=1)))

%do stats
m = max(out)+1;
s = zeros(1,m);
for i = 1:m
    s(i) = sum(out == i-1)/n;
    fprintf('Chance for %d 5*s: %0.4f\n', i-1, s(i))
end

