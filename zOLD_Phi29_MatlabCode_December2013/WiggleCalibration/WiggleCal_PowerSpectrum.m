function [f,mx] = WiggleCal_PowerSpectrum(Fsamp,Data)
% Calculate the Power Spectrum for Data acquired at Fsamp
%
% Gheorghe Chistol, 15 April 2011

% Calculate the properly scaled power-spectrum
x=Data;
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
Nfft= 2^(nextpow2(length(x))); 
% Take fft, padding with zeros so that length(fftx) is equal to nfft 
Xfft = fft(x,Nfft); 

% Calculate the numberof unique points
NumUniquePts = ceil((Nfft+1)/2); 

% FFT is symmetric, throw away second half 
Xfft = Xfft(1:NumUniquePts); 

% Take the magnitude of fft of x and scale the fft so that it is not a
% function of the length of x
mx = abs(Xfft)/length(x); 


% Take the square of the magnitude of fft of x. 
mx = mx.^2; 


% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not be multiplied by 2.


if rem(Nfft, 2) % odd nfft excludes Nyquist point
  mx(2:end) = mx(2:end)*2;
else
  mx(2:end -1) = mx(2:end -1)*2;
end


% This is an evenly spaced frequency vector with NumUniquePts points. 
f = (0:NumUniquePts-1)*Fsamp/Nfft; 

%remove the very first point since it's usually meaningless
f(1) = [];
mx(1) = [];