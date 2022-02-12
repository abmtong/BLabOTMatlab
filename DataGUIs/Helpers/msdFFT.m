function [out, acr] = msdFFT(dat)
%MSD by a FFT method. Second output is autocorrelation

%MSD = (dat(i) - dat(i+dt))^2 = (dat(i)^2 + dat(i+dt)^2) - 2*(dat(i)*dat(i+dt))
% The first term is a simple sum of squares, the second is an autocorrelation
% Citation eg https://doi.org/10.1051/sfn/201112010 section 4.1 and 4.2 (though discovered from stackoverflow)
% Results agree (slight deviations?) with loop-based MSD ( out(i) = sum((dat(i:len) - dat(1:len-i+1)).^2)/(len-i+1); )

%More detail: MSD(m) = (1/(N-m)) Sum(k=0 to N-m) (dat(k+m) - dat(k)) ^2 [zero-indexing]
% Expand the quadratic to [dat^2(k+m) + dat^2(k)] - 2* [dat(k+m)*dat(k)]. The LHS is a simple sum, the RHS is the autocorrelation
% So, calculate autocorrelation via ifft(abs(fft.^2)) [O(nlogn) speed], sum-of-squares by cumsum [O(n) speed]

dat = double(dat(:)'); %Single precision isn't good enough [well, only affects large delays so maybe don't care]

%Compute sum-of-squares term
N = length(dat);
D = dat.^2;
%Calculate S1 by cumsum in reverse (to minimize rounding errors)
ssq = fliplr( cumsum(D) + cumsum(D(end:-1:1)) ) ./ (N:-1:1);

%Compute autocorrelation ifft( abs( fft ).^2 )
%To do a non-cyclic FFT, pad the input with as many zeros
acr = ifft( abs( fft(dat, N*2) ).^2 );
acr = acr(1:N) ./ (N:-1:1); %Remove padding, normalize by number of points

out = ssq - 2 * acr;
%out(1) should be zero, maybe not because of rounding. Maybe set it as zero?

%Alternate methods of calculating ssq
%{
% %Calculating Sum of Squares: Method one: loop
% Q = 2*sum(D);
% ssq = zeros(1,N);
% ssq(1) = Q/N;
% for i = 1:N-1
%     Q = Q - D(i) - D(N-i+1);
%     ssq(i+1) = Q/(N-i);
% end

% %Method two: cumsum
% Q1 = cumsum([0 D( 1:end-1)]);
% Q2 = cumsum([0 D(end:-1:2)]);
% ssq = 2*sum(D) - Q1 - Q2;
% ssq = ssq ./ (N:-1:1);

%Method three: cumsum, reversed (to minimize rounding errors)
ssq = fliplr( cumsum(D) + cumsum(D(end:-1:1)) ) ./ (N:-1:1) ;

%ssq(end) should be D(1)+D(end), Method 3 is the most accurate in this regard
% Method 1/2 , since they subtract D(1) from 2*sum(D), are vulnerable to the accumulation of rounding errors if N is large
% Method 3 is a tad slower than 1, but insigificant (since FFT is rate determining)


%}