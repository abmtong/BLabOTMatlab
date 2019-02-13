% x = iwt(WT,S) Inverse wavelet transform
%
% WT = matrix with wavelet transform
% S = leftover low-pass time series
% x = reconstructed time series
%
function x = mal_iwt(WT,S)
[N,J] = size(WT); % J=# of scales, N=data length
% normalization coefficients
lambda = [1.5, 1.12, 1.03, 1.01];
if J > 4
    lambda = [lambda,ones(1,J-4)];
end
% filter coefficients
H = [0.125, 0.375, 0.375, 0.125];
K = [0.0078125, 0.054685, 0.171875];
K = [K, -1*fliplr(K)];
% convolution offsets
Kn = 3;
for j = 1:J-1
    znum = 2^j - 1;
    Kn = [Kn,((znum+1)/2)+2*znum+3];
end
Hn = 2;
for j = 1:J-1
    znum = 2^j - 1;
    Hn = [Hn,((znum+1)/2)+znum+2];
end
% recursively compute the inverse WT, proceeding down in
% scales, signal is odd-symmetric periodically extended
S=S(:);
S1 = [fliplr(S),S,fliplr(S)]; S1=S1(:);
for j = J:-1:1
    znum = 2^(j-1) - 1; % # of zeros
    Kz = in_zeros(K,znum); % insert zeros into K
    Hz = in_zeros(H,znum); % insert zeros into H
    WTj = WT(:,j); WTj=WTj(:);
    WT_ext = [fliplr(WTj),WTj,fliplr(WTj)]; WT_ext=WT_ext(:);
    A1 = lambda(j)*conv(Kz,WT_ext);
    A1 = A1(N+Kn(j):2*N+Kn(j)-1);
    A2 = conv(Hz,S1);
    A2 = A2(N+Hn(j):2*N+Hn(j)-1);
    S1 = A1 + A2;
    S1 = [fliplr(S1)',S1',fliplr(S1)']; S1=S1(:);
end % end IWT loop
x = S1(N+1:2*N)';
return