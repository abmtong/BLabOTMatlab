function plotsavedpwds(instruct)

n = length({instruct.con});
col = @(i,s)hsv2rgb( i / n, s, .6);

t = 0;
figure Name PWDTraces
hold on
for i = 1:n
    con = instruct(i).con;
    if iscell(con)
        con = [con{:}];
    end
    const = con(1);
    con = con - con(1) + 1000 + 10*(n-i);
    len = length(con);
    tim = (t:t+len-1)/2500;
    text(tim(1), double(con(1)), sprintf('%d %0.1fs %0.1fkb %s', i, instruct(i).time(1), const(1)/1e3, instruct(i).name))
    plot( tim, con, 'Color', [.7 .7 .7], 'LineWidth', 1)
    plot( windowFilter(@mean, tim, 5, 1), windowFilter(@mean, con, 5, 1), 'Color', col(i,1))
    t = t+len;
end
figure Name PWDPlots
hold on
for i = 1:n
    plot(instruct(i).x, instruct(i).y, 'Color', col(i,1))
end

a = [instruct.y];
a = reshape(a, [], n);
plot(instruct(i).x, mean(a,2), 'Color', 'k', 'LineWidth', 2)
xlim([0 20])
    
    