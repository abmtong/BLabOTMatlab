function out = spin(ncoin, ratio, nspin)

out = [ncoin zeros(1, nspin)];

%stardew valley wheel is 75% winrate to double, what is the optimal betting strategy?
for i = 1:nspin
    out(i+1) = out(i) + round(out(i)*ratio) * (2*floor(rand+.75)-1);
end