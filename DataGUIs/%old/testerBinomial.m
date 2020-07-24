mut = 8;
wt = 1;
pow = 5;


polyn = zeros(1,pow+1);
for i = 1:pow+1
    polyn(i) = mut^(pow-i+1)*wt^(i-1) * nchoosek(pow,i-1);
end


[[5.0 4.1 3.2 2.3 1.4 0.5];...
polyn/sum(polyn);...
[0   polyn(2:end)/sum(polyn(2:end))];...
[0 0  polyn(3:end)/sum(polyn(3:end))];...
[0 0 0  polyn(4:end)/sum(polyn(4:end))];...
[0 0 0 0 polyn(5:end)/sum(polyn(5:end))] ]