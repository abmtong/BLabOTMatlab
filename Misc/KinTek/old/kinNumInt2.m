function out = kinNumInt2()

%Numeric integration of C <> A > B [off pathway intermediate]

kab = 1;
kac = .1;
kca = .1;

dt = 1e-3;

n = 10/min(kab,kac)/dt;

a = zeros(1,n);
b = zeros(1,n);
c = zeros(1,n);
a(1) = 1;

for i = 2:n
    da = c(i-1) * kca * dt;
    db = a(i-1) * kab * dt;
    dc = a(i-1) * kac * dt;
    a(i) = a(i-1) - db - dc + da;
    b(i) = b(i-1) + db;
    c(i) = c(i-1) + dc - da;
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