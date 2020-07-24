function [a,aerr,chisq,yfit,corr] = levmar(x,y,sig,fitfun,a0,dYda,sgn)

% levmar.m Fits a nonlinear function to data using the Marquardt
%                     method discussed in Bevington and Robinson in Sections 8.5 & 8.6.
%           This method uses a variable 'lambda' to moderate an algorithm
%           between two extremes:
%           For lambda very small, solution is an 'expansion algorithm'
%           For lambda very big, solution is the gradient algorithm
%
%    Inputs:  x -- the x data to fit
%             y -- the y data to fit
%             sig -- the uncertainties on the data points
%             fitfun -- the name of the function to fit to
%             a0 -- the initial guess at the parameters
%             sgn, dYda -- if sgn=0, use numerical derivatives;
%                          if sgn=1, use analytic expressions for
%                          derivatives stored in the cell "dYda"
%    Outputs: a -- the best fit parameters
%             aerr -- the errors on these parameters
%             chisq -- the final value of chi-squared
%             yfit -- the value of the fitted function
%                     at the points in x
%             corr -- error matrix = inverse of the curvature matrix alpha
%*****************************************
%*** Parameters you may need to modify ***
%*****************************************
stepsize  = abs(a0)*0.001;              % when calculating the derivative of chi square
chicut = 0.01;                          % Stop when successive chi^2 values differ by only 'chicut'
a = a0;
chi2 = calcchi2(x,y,sig,fitfun,a);      % Algorithm STEP 1
lambda = 0.001;                         % Algorithm STEP 2
chi1 = chi2+chicut*2;
[dum,nparm] = size(a);
i=0;
fprintf(1,'Marquardt Gradient-Expansion Algorithm \n');
fprintf(1,'i \t Chisqr \t a1 \t a2 \t a3 \t a4 \t a5 \t lambda\n')
while (abs(chi2-chi1))>chicut       % Keep looking until chi-squared no longer changes
    i=i+1;
    fprintf(1,'%5.0f', i);
    fprintf(1,'% 8.1f', chi2);
    fprintf(1,'% 8.3f',a);
    fprintf(1,'% 8.3e',lambda);
    fprintf(1,'\n');
    chinew = chi2 + 1;
      while chinew>chi2+chicut      % Algorithm STEP 3
        deltaa = calcdeltaa(x,y,sig,fitfun,a,stepsize,lambda,dYda,sgn);     
        anew   = a + deltaa;
        chinew = calcchi2(x,y,sig,fitfun,anew);
        if chinew>chi2              % Algorithm STEP 4
         lambda = lambda*10;        % If chi-square increses, increase lambda (x10) and repeat STEP 3
        end
      end
    lambda = lambda/10;             % Algorithm STEP 5
                                    % If chi square decreases, decrease lambda (x10), consider
    a      = anew;                  % 'anew' to be the new starting point, and return to STEP 3
    chi1   = chi2;
    chi2   = chinew;
end
corr = calcinvalpha(x,y,sig,fitfun,a,stepsize,lambda,dYda,sgn);
for i=1:nparm
   aerr(i) = sqrt(corr(i,i));
end
chisq = calcchi2(x,y,sig,fitfun,a);
yfit = feval(fitfun,x,a);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting is done, return to main program
% Everything below here are functions used in the Marquardt Algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function just calculates the value of chi^2
function chi2 = calcchi2(x,y,sig,fitfun,a)
    chi2 = sum( ((y-feval(fitfun,x,a)) ./sig).^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function calculates the value of deltaa according to the current
% choice of a. See bevington p. 157 equation (8.28)
function deltaa = calcdeltaa(x,y,sig,fitfun,a,stepsize,lambda,dYda,sgn)
  [dum,nparm] = size(a);
  [ndata,dum] = size(x);
  beta = zeros(1,nparm);
  corr = calcinvalpha(x,y,sig,fitfun,a,stepsize,lambda,dYda,sgn);
  der = calcderiv(x,y,sig,fitfun,a,stepsize,dYda,sgn);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % This loop calculates the row-vector beta from Bevington Equation 8.37
  % The FORTRAN implementation is from pg. 293, Program 8.6
  % Loosely speaking, beta is the first term in the 2nd order Taylor
  % expansion y(x).
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for k=1:nparm
    for i=1:ndata
       beta(k) = beta(k)+(y(i)-feval(fitfun,x(i),a))*der(i,k)/sig(i)/sig(i);
    end
  end
  deltaa = beta*corr;	% Bevington Equation 8.28

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function calculates the square 'curvature' matrix alpha and its inverse 
% matrix also known as the 'error' matrix which contains the correlation
% coeffieients between the best fit paratmeter estimates.
% See Bevington p. 159 eq.(8.37) and Page 293, Program 8.6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function corr = calcinvalpha(x,y,sig,fitfun,a,stepsize,lambda,dYda,sgn);
    [dum,nparm] = size(a);
    [ndata,dum] = size(x);
    alpha = zeros(nparm,nparm);
    der = calcderiv(x,y,sig,fitfun,a,stepsize,dYda,sgn);
    for j=1:nparm
        for k=1:nparm
            for i=1:ndata
                alpha(j,k) = alpha(j,k)+der(i,j)*der(i,k)/sig(i)/sig(i);
            end
        end
    end

    for j=1:nparm       % As in Equation 8.39, scale the diagonal elements of alpha to
                        % control the interpolation of the algorithms
                        % between the two extremes.
        alpha(j,j) = (1+lambda)*alpha(j,j);
    end
    corr = inv(alpha);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this function calculates the values of dY[i]/da[j] for all i and j
function der = calcderiv(x,y,sig,fitfun,a,stepsize,dYda,sgn)

[dum,nparm] = size(a);
[ndata,dum] = size(x);
der = zeros(ndata,nparm);

% if sgn=0, use numerival derivatives
if sgn==0
   for i=1:ndata
       y0 = feval(fitfun,x(i),a);
       for j=1:nparm
           a(j) = a(j) + stepsize(j);
           y1 = feval(fitfun,x(i),a);
           a(j) = a(j) - stepsize(j);
           der(i,j) = (y1-y0)/stepsize(j);	% Bevington Equation A.24
       end
   end
else   % if sgn=1, use the analytic expressions for derivatives
   for i=1:ndata
       for j=1:nparm
           der(i,j) = feval(dYda{j},x(i),a);
       end
   end
end