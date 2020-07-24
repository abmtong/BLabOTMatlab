function P = Ghe_PowerSpectrum_Aliased_DiodeFiltered(scal_fit,parameters,f)
% This function generates the power spectrum, taking into account aliasing
% and parasitic filtering by the diode.
% scal_fit   - is the scaled fit parameter
% parameters - [Fc D F3db ]
% Gheorghe Chistol, 27 April 2011
fSample = 62500; %acquisition frequency, Hertz

Fc      = parameters(1)*scal_fit(1);
D       = parameters(2)*scal_fit(2);
F3db    = parameters(3)*scal_fit(3);
a0      = parameters(4)*scal_fit(4);
alpha   = 1 / sqrt(1 + a0^2); %I still don't understand why this is being done this way...
                              %maybe it converges faster, or is
                              %re-normalized better for fitting this way?
                              
%% Take into account Aliasing and Parasitic Filtering from Detector
% See the Tolic-Norrelykke et al. Computer Physics Communications 159 (2004) 225-240, pg 230 for more details
% We measure Paliased, while Ptheory is the correct form
% f is the frequency (variable, x-axis), fSample is for us 62.5kHz, could be something else in general
% Paliased = SUM(N = -Inf to + Inf) of Ptheory(f+N*fSample)

Nalias  = 20; %Default value for number of aliasing terms

% Here we create a matrix ff that is used to take into account aliasing, this is now becoming a frequency matrix
ff = zeros(length(f),length(-Nalias:Nalias));
for i= 1: length(f)
    ff(i,:) = f(i) +(-Nalias:Nalias)*fSample;
end

% See the Tolic-Norrelykke et al. Computer Physics Communications 159 (2004) 225-240, pg 230 for more details
% P(f)measured/P(f)actual = alpha^2 + (1-alpha^2)/(1+f^2/f3db^2)
% Diode correction factor, Gain in other words
Gdiode  = alpha^2 + (1-alpha^2) ./ (1 + (ff/F3db).^2); 
P       = sum( (D/(2*pi^2))./(ff.^2+Fc^2).*Gdiode );

%The original TweezerCalib2.1 had some extra factor due to additional
%electronic filters. I got rid of that