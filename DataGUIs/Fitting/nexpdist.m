function out = nexpdist(n, ver)
%A sum of N exp's

%ver is whether a1 is a variable (ver=1) or implicitly 1 (ver=2)

if nargin < 2
    ver = 1;
end

exppdf = @(x,a,k) a * k * exp(-x*k); %#ok<NASGU>
expcdf = @(x,a,k) a * exp(-x*k); %#ok<NASGU> %Actually the ccdf

%Use eval to assemble the function handle, as there's no great way to do so otherwise(?)
str1 = sprintf(',a%d,k%d', [1:n ; 1:n]); %',aI,kI'
str2 = sprintf('exppdf(x,a%d,k%d)+', [1:n ; 1:n]); %'expcdf(x,aI,kI)+'
str2b= sprintf('expcdf(x,a%d,k%d)+', [1:n ; 1:n]); %'exppdf(x,aI,kI)+'
str3 = sprintf('a%d+', 1:n); %'aI+'

if ver == 1 %f(x,a1,k1,a2,k2,...)
    out.lb = repmat([0 0], 1, n);
    out.ub = repmat([inf inf], 1, n);
    out.cmt = sprintf('Sum of %d exponentials, height aI and rate kI', n);
elseif ver == 2 %Set a1 == 1, should work better with MLE (makes ai's independent)
    %Strip ',a1' from str1, replace 'a1' with '1' in others
    str1 = strrep(str1, ',a1','');
    str2 = strrep(str2, 'a1','1');
    str2b= strrep(str2b,'a1','1');
    str3 = strrep(str3, 'a1','1');
    out.lb = zeros(1,2*n-1);
    out.ub =   Inf(1,2*n-1);
    out.cmt = sprintf('Sum of %d exponentials, height aI and rate kI. a1 = 1 (not passed)', n);
end

out.pdf = eval( sprintf( '@(x%s) ( %s 0 ) / (%s 0)', str1, str2 , str3 ));
out.cdf = eval( sprintf( '@(x%s) ( %s 0 ) / (%s 0)', str1, str2b, str3 ));

%Eps out the minimum?
% warning('Using an exp dist with a probability floor')
% out.pdf = eval( sprintf( '@(x%s) max(eps(max(x)), ( %s 0 ) / (%s 0))', str1, str2 , str3 ));
% out.cdf = eval( sprintf( '@(x%s) max(eps(max(x)), ( %s 0 ) / (%s 0))', str1, str2b, str3 ));