function [out, S2] = msdFFT(dat)
%MSD by a FFT method. Second output is autocorrelation

%MSD = dat^2--like_term - 2*acorr
% from https://stackoverflow.com/questions/34222272/computing-mean-square-displacement-using-python-and-fft
% Results agree (slight deviations?) with loop-based MSD ( out(i) = sum((dat(i:len) - dat(1:len-i+1)).^2)/(len-i+1); )

dat = dat(:)';

%Compute dat^2--like term
N = length(dat);
D = [dat.^2 0];
Q = 2*sum(D);
S1 = zeros(1,N);
S1(1) = Q/N;
for i = 1:N-1
    Q = Q - D(i) - D(end-i+1);
    S1(i+1) = Q/(N-i);
end

%Compute autocorrelation ifft( abs( fft ).^2 )
%To do a non-cyclic FFT, pad the input with as many zeros (= fft(dat, length(dat)*2))
S2 = ifft( abs( fft(dat, N*2) ).^2 );
S2 = S2(1:N); %Remove padding
S2 = S2 ./ ( N - (0:N-1) ) ; %Weight by number of points

out = S1 - 2 * S2;

%Copy of stackoverflow code
%{
def autocorrFFT(x):
  N=len(x)
  F = np.fft.fft(x, n=2*N)  #2*N because of zero-padding
  PSD = F * F.conjugate()
  res = np.fft.ifft(PSD)
  res= (res[:N]).real   #now we have the autocorrelation in convention B
  n=N*np.ones(N)-np.arange(0,N) #divide res(m) by (N-m)
  return res/n #this is the autocorrelation in convention A

def msd_fft(r):
  N=len(r)
  D=np.square(r).sum(axis=1) 
  D=np.append(D,0) 
  Q=2*D.sum()
  S1=np.zeros(N)
  for m in range(N):
      Q=Q-D[m-1]-D[N-m]
      S1[m]=Q/(N-m)
  S2=sum([autocorrFFT(r[:, i]) for i in range(r.shape[1])])
  return S1-2*S2
%}