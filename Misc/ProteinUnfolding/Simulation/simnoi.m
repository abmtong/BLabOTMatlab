function out = simnoi(frc)


%Eh just try to match the curve from Alan paper

%roughly:
% fh = @(xx) exp(-xx*.5)*2 + exp(-xx*.1)*1 +  1.7 ;
fh = @(xx)exp(-xx*.5)*2 + exp(-xx*.08)*1.1 +  1.6 ;
%a little under at 5-10pN , a little over at 20-30

out = fh(frc);

%Looking at two Ross data at different trapk's, 
% it looks like the ext noise is constant, the force noise goes with k. So let's compare nm noise and nm signal

