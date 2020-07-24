function y = mean_nan(x)

%Finds mean of x ignoring nan's

%%Protect against bad input
%**********************************************
if (isnan(x) == 1)
    y = NaN;
    return
end

if isempty(x) % if empty return
    y = NaN;
    return
end

if (size(x,1)> 1 & size(x,2) > 1) % check for matrix input
    disp('mean_nan requires a vector input and cannot handle matrix input')
    return
end

%**********************************************
not_nums = isnan(x);
index = find(not_nums);
x(index) = zeros(size(index)); %set nan to zero

length_x = length(x)-sum(not_nums);
y = sum(x)./length_x;

