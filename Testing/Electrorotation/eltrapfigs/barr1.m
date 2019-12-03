function barr1()
%Is simulating the 'energy landscape' useful? or no

barrpos = 0;
barrsd = 3;
barrht = 1;
barrv = @(x) normpdf(x, barrpos, barrsd) * barrht;

trappos = 0;
trapstr = .001;
trapv = @(x) (x-trappos).^2*trapstr;


%Plot trap potential and barrier potential individually, then their sum

xx = -20:0.1:20;

barry = barrv(xx);

trapy = trapv(xx);

figure Name Barrier1

plot(xx,barry, 'Color', 'b')
hold on
plot(xx,trapy, 'Color', 'r')

plot(xx, barry+trapy, 'Color', 'k')