function testerMean()
a = 1:1e2;

for i = 1:1e6
    b = mean(a);
    c = sum(a)/length(a);
end

isequal(b,c)

end