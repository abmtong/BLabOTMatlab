function [a,aerr,chisq,yfit] = fitlin(x,y,sig)

% FITLIN Fit a linear function to data.
%    [a,aerr,chisq,yfit] = fitnonlin(x,y,sig) 
%
%    Inputs:  x -- the x data to fit
%             y -- the y data to fit
%             sig -- the uncertainties on the data points
%
%    Outputs: a -- the best fit parameters
%             aerr -- the errors on these parameters
%             chisq -- the value of chi-squared
%             yfit -- the value of the fitted function
%                     at the points in x
%                                                                                                                                                                                                                                                               

% The least-squares fit to a straight line can be done in closed form
% See Bevington and Robinson Ch. 6 (p. 114).

term1=sum(1./sig.^2);
term2=sum(x.^2./sig.^2);
term3=sum(y./sig.^2);
term4=sum(x.*y./sig.^2);
term5=sum(x./sig.^2);

delta=term1*term2-term5^2;
a(1)=(term2*term3-term5*term4)/delta;
a(2)=(term1*term4-term5*term3)/delta;

aerr(1)=sqrt(term2/delta);
aerr(2)=sqrt(term1/delta);

yfit = a(1) + a(2)*x;

chisq = sum(((y-a(1)-a(2)*x)./sig).^2);