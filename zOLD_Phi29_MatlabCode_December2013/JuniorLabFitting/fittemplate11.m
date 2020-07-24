%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: http://web.mit.edu/8.13/matlab/fittemplate11.m
% Contributors: JLAB Staff, Jim Kiger, William McGehee, Xuangcheng Shao
% Last Updated: 2011-Oct-25
%
%
% This Matlab script is intended to be used for linear and non-linear
% fitting problems in experimental physics.
%
% It closely follows the material presented in 
% "Data Reduction and Error Analysis for the Physical Sciences: 3rd Editon"
% by Philip R. Bevington and D. Keith Robinson
% Students are responsible for understanding the underlying methods,
% DO NOT USE THIS SCRIPT AS A BLACK BOX!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%clear;                      % Clears all variables from memory

%load bev81.txt;             % Loads sample data set 'bev81.txt' (Bevington Table 8.1, pg. 144)
%x = bev81(:,1);             % Assigns the first column of mydata to a vector called 'x'
%y = bev81(:,2);             % Assigns the second column of mydata to a vector called 'y'
%sig = sqrt(y);              % sets sigma to the square root of 'y' for Poisson statistics

%load gauss3.dat;             % Load and prepare the gauss1.txt NIST dataset
x=Data.Ind/100;
y=Data.kAY;
sig=Data.kAYstd;       % Constant error value, variance (=sigma^2) of gauss3 data set is 6.25

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There are other ways to assign your error vector
% You might want to use one of these three methods below.
% sigma = 2.5;                  % Constant error value, variance of gauss3 data set is 6.25.
% sig = ones(size(x))*sigma;    % creates a constant vector the same size as 'x' w/value sigma
% sig = mydata(:,3);            % Assigns the third column to a vector called
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% At this point you should know whether you want to perform a 'linear' or 'non-linear fit 
% to your data set.  Select and uncomment the appropriate section to proceed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% ** LINEAR FITS **
% If you wish to fit your data to a straight line, you can use the function
% 'fitlin.m'  This function is also taken directly from the pages of Bevington 
% and Robinson Ch. 6 (p. 114) and it is very easy to follow.  The usage of
% fitlin is as follows:
%
% [a,aerr,chisq,yfit] = fitlin(x,y,sig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ** NON-LINEAR FITTING **
% For non-linear fits, you will need to create a Matlab 'function handle' for your model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some useful non-linear model functions are listed here:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function_Exp        = @(x,a) a(1)-a(2)*exp(-a(3)*(x-a(4)));
a0 = [0.1 3.6 2 1];

% function_sin        = @(x,a) a(1)*sin(a(2)*x+a(3));
% function_gaussian   = @(x,a) a(1)*(exp(-((x-a(2))/a(3)).^2));
% function_lorentzian = @(x,a) a(1)*(a(2)/(2*pi)./(((x-a(3)).^2)+(a(2)^2/4)));
% function_poisson    = @(x,a) a(1)*exp(x*log(a(2))-a(2)-gammaln(x+1);
% function_NIST       = @(x,a) a(1)*exp(-a(2)*x) +...
%                              a(3)*exp(-((x-a(4)).^2)/a(5)^2) +...
%                              a(6)*exp(-((x-a(7)).^2)/a(8)^2);
% function_bev82      = @(x,a) a(1)+a(2)*exp(-x/a(4))+a(3)*exp(-x/a(5));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For non-linear fits using the Levenberg-Marquardt method, if you want to use
% analytic expressions instead of numerical derivatives (not very common), enter the
% expressions for derivatives in the following cell dYda, and let sgn be 1
% instead of 0. Note: the definition of dYda cannot be commented out since
% it has to be defined no matter whether it is actually used.
sgn=0;  % Ignore the following analytic derivatives and calculate them numerically instead (usual case)
dYda={@(x,a) 1,
     @(x,a) exp(-x/a(4)),
     @(x,a) exp(-x/a(5)),
     @(x,a) a(2)/a(4)^2*exp(-x/a(4)).*x,
     @(x,a) a(3)/a(5)^2*exp(-x/a(5)).*x};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a vector containing your initial estimates for the model
% parameters.  It is important to make good estimates of these initial
% values to ensure that you chi-squared minimization doesn't occur in a
% 'local' minimum.
% a0 = [10 900 80 27 225];              % Initial parameter estimates for Bevington Ch. 8 Dataset
% a0 = [94 .0105 99 63 25 71 180 20];   % Initial estimates for gauss1.txt
%a0 = [94 .009 90.1 113 20 73.8 140 20]; % Initial estimates for gauss3.txt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Selection of Chi-Squared Minimization Algorithm
% Junior Lab Techincal Staff have written two Matlab fitting scripts which you may find useful:
% 'levmar.m' implements the Marquardt Method:
%             Bevington and Robinson Section 8.6, Page 161
% 'gradsearch.m' implements the Gradient-Search Method
%             Bevington and Robinson Section 8.4, Page 153
%
% To select the 'levmar.m' fitting script, set algselect=0.
% To select the 'gradsearch.m' fitting script, set algselect=1.
%
algselect=1;
if algselect==0
	[a,aerr,chisq,yfit,corr] = levmar(x,y,sig,function_NIST,a0,dYda,sgn);
else 
	[a,aerr,chisq,yfit] = gradsearch(x,y,sig,function_Exp,a0);
end
%
%    Inputs:  x         -- the x data to fit
%             y         -- the y data to fit
%             sig       -- the uncertainties on the data points
%             fitfun    -- the name of the function to fit to
%             a0        -- the initial guess at the parameters   
%             dYda      -- analytical derivatives for fitting function
%             sgn       -- flat to select analytical or numerical derivatives
%
%    Outputs: a         -- the best fit parameters
%             aerr      -- the errors on these parameters
%             chisq     -- the final value of chi-squared
%             yfit      -- the value of the fitted function at the points in x
%             corr      -- error matrix = inverse of the curvature matrix alpha (output from levmar.m only)
%
%
% IMPORTANT NOTE  - since both levmar.m and gradsearch.m are iterative algorithms, you can vary
% the step size and tolerance used in the fitting process.  These are
% specified within the subroutines 'levmar.m' and 'gradsearch.m'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Always report statistics on the 'Goodness of Fit'
%%% More information can be found in Bevington's Appendix C and                              
%%% in Matlab's Online Help searching under 'goodness of fit' 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'Uncertainties');
fprintf(1,'%9.1e',aerr);
fprintf(1,'\n');
level = 0.68;                   % confidence level 68% =1-sigma, 95% = 2-sigma
dof  = length(x) - length(a);
fprintf(1,'Degrees of Freedom = %5d \n',dof);
RChiSquare = chisq/dof';
prob=100*(1-chi2cdf(chisq,dof)); % This is the Matlab equivalent of Bevington Table C.4
fprintf(1,'Reduced Chi-Squared=%6.2f; probability=%6.1f percent \n',RChiSquare,prob);
if algselect==0
	fprintf(1,'\n Elements of the error matrix (Marquardt method only)\n');
	for i=1:length(a)
		fprintf(1,'%10.4f',corr(i,:));
		fprintf(1,'\n');
	end
end
residuals = y-yfit;
rss=sum(residuals.^2);
rstd=std(residuals);
fprintf(1,'Residual Sum of Squares = %8.3f \n',rss);
fprintf(1,'Residual Standard Deviation = %8.3f \n',rstd);
fprintf(1,'\n');
[a',aerr']

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ** Confidence Intervals **
% The confidence bounds for fitted coefficients are given by
% [b-t*sqrt(S),b+t*sqrt(S)].
% b are the coefficients produced by the fit, t depends on the confidence
% level, and is computed using the inverse of student's t cumulative 
% distribution function, S is the vector of diagonal elements from the
% estimated covariance matrix.  'aerr' is the square root of 'S'
width = tinv(level,dof)*aerr; 
lower = a - width;
upper = a + width;
FitResults = [a', lower', upper'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we plot the basic figure.  Be sure to double check the sizes and colors
% of all your labels and markers to ensure their visibility to your audience.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure();
%subplot(2,1,1);
errorbar(x,y,sig,'.');
%axis([0 250 0 150]);
hold on;
plot(x,yfit,'r','LineWidth',3);
xlabel('Mirror X Voltage (V)','fontsize',12);  
ylabel('Stiffness (pN/nm)','fontsize',12);
%title({'Descriptive Title: e.g. Determination of Fine Structure Splitting in Hydrogen'},'fontsize',12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A certain amount of information placed on a graph can make it more easily
% understood by an audience who perhaps cannot hear everything you say
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

str1=num2str(RChiSquare,2);
text(5,25,['\chi^2_{\nu-1} = ' str1]);
text(5,10,['Probability =' num2str(prob,2),' %']);

%str1=num2str(a(7)-a(4),3);
%str2=num2str(sqrt(width(7)^2+width(4)^2),1);
%text(115,55,['Fit Energy Splitting']);
%text(122,45,['(b_3 - b_2)']);
%text(119,35,[str1 ' \pm ' str2 ' nm']);
%plot(zeros(size(y))+a(4),y,'r-');
%plot(zeros(size(y))+a(7),y,'r-');
%text(5,125,'Model: y(x) =a_1e^{-b_1x}+a_2*e^{-((x-b_2)/c_2)^2}+a_3*e^{-((x-b_3)/c_3)^2}','fontsize',12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Residuals qualitatively demonstrate the agreement between the model
% function with the best fit parameters and the data being modeled
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot(2,1,2);
% plot(x,zeros(size(x)),'r-');
% hold on;
% plot(x,residuals,'b.'); 
% xlabel('X-Axis Label [units]','fontsize',12);  
% ylabel('Y-Axis Label [units]','fontsize',12);
% title({'Residuals should have \mu = 0 and lack structure','Use graphics to guide the eye...e.g. red line at zero'},'fontsize',12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other scientific disciplines use a variety of related terms related to
% the evaluation of 'Goodness of Fit'.  In order to help you understand
% some of these terms, found in the Matlab help system, we list here some
% useful definitions.
% ---------------------   Curve Fitting Definitions   ------------------
%
% y = response value
% y_tilde = fit to the response value
% y_bar = mean
%
% SSE (Sum of Squares due to Error)  = weighted sum of (y - y_tilde)^2.
% SSR (Sum of Squares of Regression) = weighted sum of (y_tilde - y_bar)^2
% SST (Total Sum of Squares)         = weighted sum of (y - y_bar)^2
% It follows then that SST = SSE + SSR
%
% R-square = SSR / SST = 1 - (SSE / SST)
% v - degree of freedom
% v = n - m (number of response values - number of fitted coefficients)
%
% Adjusted R-square = 1 - (SSE / SST) * (n - 1) / v
% Adjusted R-square <= 1
% 1, with a value closer to 1 indicating a better fit.
% MSE (Mean Squared Error) = SSE / v (the same as R-chi-square)
% RMSE (Root Mean Squared Error) = sqrt(MSE) 
% A RMSE value closer to 0 indicates a better fit.
% ----------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    