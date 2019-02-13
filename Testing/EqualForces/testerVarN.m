figure
hold on
for i = 1:50
    for j = 1:50
        plot(i, var(rand(1,2^i)),'o');
    end
end