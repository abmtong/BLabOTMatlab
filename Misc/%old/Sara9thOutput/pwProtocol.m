function y = pwProtocol(Params,t)
x0 = Params(1);
m = Params(2);
xl = Params(3);
y = zeros(1,length(t));
for i = 1:length(t)
    if(i <= xl)
        y(i) = x0;
    else
        y(i) = x0 - m*(i-xl);
    end
end

end