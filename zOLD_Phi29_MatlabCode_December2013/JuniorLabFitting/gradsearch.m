function [a,aerr,chisq,yfit] = gradsearch(x,y,sig,fitfun, a0)

%  This function fits a nonlinear model to data using the gradient search 
%           method discussed in Bevington and Robinson in Section 8.4.
%           This function is usually called from within a parent script (e.g.
%           fittemplate08.m) in which the input vectors are contructed.
%*****************************************
%*** Parameters you may need to modify ***
%*****************************************
stepsize = abs(a0)*0.01; % amount parameters will be varied in order to determine the derivative
stepdown = .1;
chicut = 0.1;  % Maximum differential allowed between successive chi^2 values

a = a0;
chi2 = calcchi2(x,y,sig,fitfun,a);
chi1 = chi2+chicut*2;
i=0;
fprintf(1,'i \t Chisqr \t a1 \t a2 \t a3 \t a4 \t a5\n')
while (abs(chi2-chi1))>chicut
    i=i+1; 
    fprintf(1,'%5.0f', i);
    fprintf(1,'% 8.1f', chi2);
    fprintf(1,'% 8.1f',a);
    fprintf(1,'\n');
    [anew,stepsum] = gradstep(x,y,sig,fitfun,a,stepsize,stepdown);
    a = anew;
    stepdown = stepsum;
    chi1 = chi2;
    chi2 = calcchi2(x,y,sig,fitfun,a);
end
    fprintf(1,'Final');
    fprintf(1,'% 8.1f', chi2);
    fprintf(1,'% 8.1f',a);
    fprintf(1,'\n');
% calculate the uncertainties on the best fit parameters
aerr = sigparab(x,y,sig,fitfun,a,stepsize);
chisq = calcchi2(x,y,sig,fitfun,a);
yfit = feval(fitfun,x,a);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following function calculates the (negative) chi^2 gradient at
% the current point in parameter space, and moves in that direction
% until a minimum is found.  It returns the new value of the parameters
% and the total length traveled.  It's FORTRAN equivlanet is Program 8.2 in
% Appendix E on pages 290-291, Subroutine GRADLS
function [anew,stepsum] = gradstep(x,y,sig,fitfun,a,stepsize, stepdown)
  chi2 = calcchi2(x,y,sig,fitfun,a);
  grad = calcgrad(x,y,sig,fitfun,a,stepsize);
  chi3 = chi2*1.1;
  chi1 = chi3;
  stepdown = stepdown*2;
while chi3>chi2             % cut down the step size in parameter space until a single step in
  stepdown = stepdown/2;    % the direction of the negative gradient yields a decrease in chi^2
  anew = a+stepdown*grad;
  chi3 = calcchi2(x,y,sig,fitfun,anew);
end
stepsum = 0;
while chi3<chi2               % keep going in this direction until a minimum is passed
  stepsum = stepsum+stepdown;
  chi1 = chi2;
  chi2 = chi3;
  anew = anew+stepdown*grad;
  chi3 = calcchi2(x,y,sig,fitfun,anew);
end
step1 = stepdown*((chi3-chi2)/(chi1-2*chi2+chi3)+.5);% approximate the minimum as a parabola (pg. 147)
anew = anew - step1*grad;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function just calculates the value of chi^2
function chi2 = calcchi2(x,y,sig,fitfun,a)
    chi2 = sum( ((y-feval(fitfun,x,a)) ./sig).^2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function calculates the (negative) gradient at a point in 
% parameter space (See Bevington p. 154).
function grad = calcgrad(x,y,sig,fitfun,a, stepsize)
f = 0.01;
[dum, nparm] = size(a);
grad = a;
chisq2 = calcchi2(x,y,sig,fitfun,a);  
for i=1:nparm
  a2 = a;
  da = f*stepsize(i);
  a2(i) = a2(i)+da;
  chisq1 = calcchi2(x,y,sig,fitfun,a2);
  grad(i) = (chisq2-chisq1);
end
t = sum(grad.^2);
grad = stepsize.*grad/sqrt(t);  % Equation 8.20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function calculates the errors on the final fitted 
% parameters by approximating the minimum as parabolic
% in each parameter (See Bevington, p. 147).
function err=sigparab(x,y,sig,fitfun,a,stepsize)
[dum, nparm] = size(a);
err = a;
chisq2 = calcchi2(x,y,sig,fitfun,a);  
for i=1:nparm
  a2 = a;
  da = stepsize(i);
  a2(i) = a2(i)+da;
  chisq3 = calcchi2(x,y,sig,fitfun,a2);
  a2(i) = a2(i)-2*da;
  chisq1 = calcchi2(x,y,sig,fitfun,a2);
  err(i)=da*sqrt(2/(chisq1-2*chisq2+chisq3));
end