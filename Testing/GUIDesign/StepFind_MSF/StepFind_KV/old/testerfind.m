function testerfind()

function ii = quickFind()
for ii = 1:length(a)
    if a(ii) == 1
        return
    end
end
a = 0;
end

a = zeros(1,100);
a(1) = 1;

tic
for i = 1:1000
find(a);
end
toc

tic
for i = 1:1000
quickFind();
end
toc


end