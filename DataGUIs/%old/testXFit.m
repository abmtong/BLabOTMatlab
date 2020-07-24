function outS = testXFit(inContour, inInds)
%Replaces the true fit with steps placed in the middle of the plateaus
%Calculates S = QE(counter)/QE(real);

%inInds = [1 stepInd end], so length-2 steps
n = length(inInds)-2;

%Counterfit: fit a step to each found plateau
%Store QE for fit and counterfit
xcs = zeros(1,n+1);
rcs = zeros(1,n+2);
xind = [1 round((inInds(1:end-1) + inInds(2:end))/2) n];
for j = 1:n+1
    rcs(j) = C_qe(inContour(inInds(j):inInds(j+1)-1 ));
end
for j = 1:n+2
    xcs(j) = C_qe(inContour(xind(j):xind(j+1)-1 ));
end
outS = sum(xcs) / sum(rcs);