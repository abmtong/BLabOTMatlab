function [WT,S] = mal_fwt(J, x)
%Calculates the discrete, forward wavelet transform of input singal x for J iters
%Outputs the wavelet xform matrix WT and the remaining signal S

%Check input data x
if isvector(x)
    %Make it a row vector
    x=x(:)';
else
    error('Input data must be a vector')
end
len = length(x);

%Normalization coefficients
lambda = [1.5, 1.12, 1.03, 1.01];
%Pad with ones if longer
if J > 4
    lambda = [lambda,ones(1,J-4)];
end

%Filter coefficients
H = [0.125, 0.375, 0.375, 0.125];
G = -1*[-2.0, 2.0];

%Store results here
WT = zeros(len, J);
S = x;

%Compute WT at each scale
for j = 1:J
    %Calculate number of zeros to add
    znum = 2^(j-1) - 1;
    %Calculate convolution offsets Gn, Hn
    Gn = (znum+1)/2 +1;
    Hn = (znum+1)/2 +znum+2;
    if j==1 %special case: znum = 0, so Gn, Hn fractional - round up
        Gn = 2;
        Hn = 3;
    end
    %Pad with zeros
    Gz = in_zeros(G,znum);
    Hz = in_zeros(H,znum);
    %Make Signal odd symmetric aboud bdy
    S = [fliplr(S),S,fliplr(S)]; %#ok<AGROW>
    %Compute WT
    Wf = conv(S,Gz)/lambda(j);
    Wf = Wf(len+Gn:2*len+Gn-1);
    WT(:,j) =  Wf';
    %Compute next Signal
    S = conv(S,Hz);
    S = S(len+Hn:2*len+Hn-1);
end