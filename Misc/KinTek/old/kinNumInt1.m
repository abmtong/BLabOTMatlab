function out = kinNumInt1()

%Numeric integration of A > B > C

kab = 10;
kbc = 1;

dt = 1e-3;

n = 10/min(kab,kbc)/dt;

a = zeros(1,n);
b = zeros(1,n);
c = zeros(1,n);
a(1) = 1;

for i = 2:n
    %db = a * kab * dt
    db = a(i-1) * kab * dt;
    dc = b(i-1) * kbc * dt;
    a(i) = a(i-1) - db;
    b(i) = b(i-1) + db -dc;
    c(i) = c(i-1) + dc;
end

figure, hold on
plot(a)
plot(b)
plot(c)
% set(gca, 'YScale', 'log')

figure, hold on
plot (1-a)
plot(1-b)
plot(1-c)
set(gca, 'YScale', 'log')