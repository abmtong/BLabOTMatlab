function [param, resnorm, r, J, x] = GheCalibrate_FitNonlin(f,param,Tolf,MaxIter,varargin)
% Solves the problem:   
% min(sum(f(x,y...,param).^2)),  with respect to the parameters in vector 'param'
%
% GheCalibrate_FitNonlin fits an inline expression or trial function 'f' to
% the data given in the vectors in 'varargin' (see help on 'varargin') with
% initial fitting parameters contained in the vector 'param'. When the
% error decreases less than Tolf during one iteration, the results are
% returned. lsqcurvefit
%
% resnorm is the 2-norm of the final residues
% r is the final residue vector
% J is the final Jacobian matrix
% x is a structure containing information on default settings and is
% displayed automatically if required arguments are missing 
%
% USE: [param, resnorm, r, J, x] = GheCalibrate_FitNonlin(f,param,Tolf,MaxIter,varargin)
%
% Gheorghe Chistol, 3 Feb 2012

defaultopt = struct('MaxIter',50,'Trust_region_initial_value', 2000,...
                    'LineSearchType','Backtracking','Method','LevenbergMarquardt',...
                    'call_syntax','[param,resnorm,r,J,x]=GheCalibrate_FitNonlin(f,param,Tolf,varargin)'); 

% If just 'defaults' passed in, return the default options in X
if ((nargin < 1  || nargout < 1)) 
    x = defaultopt;
    disp(x)
    return
end
if nargin < 3
    error('GheCalibrate_FitNonlin requires three input arguments');
end

if (Tolf < 1e-16 || Tolf > 1e-6) %ensure reasonable values for Tolf
    Tolf = 1e-10;
end

format short                    
try
    feval(f,param,varargin{:});
catch
    error('GheCalibrate_FitNonlin: Function cannot be evaluated, try changing your options')
end

if any(isnan(feval(f,param,varargin{:})))
    param = param +1;   %Try rescue some unlucky input guesses
end
if any(isinf(feval(f,param,varargin{:})))
    param = param +1;   %Try rescue some unlucky input guesses
end
r = feval(f,param,varargin{:});

r = r(:);
m = length(param);
p = param;          %Vector of parameters
iter = 0;   
f0 = 0;             %LS error
f1 = 1;             %LS error after trial step
delta_trust = 2000; %Size of trust region
ii = 0;
ndpp = 0;
gamma = 1.5;        
MaxDelta = 1e-1;    %Max change of parameters 
MinDelta = 1e-8;    %Min change of parameters
e_e = 1e-1; 

%disp('----------------------------Start fit-------------------------------------------')
%output_disp = sprintf('\n Iteration#          Least square error         |dp|');
%disp(output_disp);
%disp('  ')
fprintf('Progress: '); %print to screen, then print a bar for each iteration

rdr     = zeros(length(r),1);                       %Residual after trial step
J = zeros(length(r),length(p));                     %Jacobian
delta(p == 0) = ones(length(p(p==0)),1)';
delta(p ~= 0) = 1e-7*abs(p(p~=0));
delta = sign(delta + eps).*min(max(abs(delta),MinDelta),MaxDelta);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Finite difference Jacobian evaluation
for k = 1:m
    p(k)    = p(k)+delta(k);
    rdr     = feval(f,p,varargin{:});
    J(:,k)  = (rdr - r)/delta(k);
    p(k)    = p(k)-delta(k);
end

%%%%%%%%%%%%%%%%%Main loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while (abs(f0-f1) > Tolf && iter < MaxIter)
    lambda = 1e-1;
    iter = iter+1;
    
    %First calculating the Jacobian J and Hessian H
    delta(p == 0) = ones(length(p(p==0)),1)';
    delta(p ~= 0) = 1e-7*abs(p(p~=0));
    delta = sign(delta + eps).*min(max(abs(delta),MinDelta),MaxDelta);  
    
    %Finite difference Jacobian evaluation
    for k = 1:m
        p(k)    = p(k)+delta(k);
        rdr     = feval(f,p,varargin{:});
        J(:,k)  = (rdr - r)/delta(k);
        p(k)    = p(k)-delta(k);
    end
    f0 = .5*norm(r)^2;
    H  =  J'*J;         %Hessian assumes small residues or linear residues
    gradf = J'*r;       %Gradient of f
    M  =  H+lambda*eye(m);
    lambda_max = norm(M)+(1+e_e)*(norm(gradf)/delta_trust);
    if (rcond(M) <= eps) 
        disp('Hessian  matrix is close to singular, lambda is increased');
        lambda = lambda_max;    
        M=H+lambda*eye(m); 
        if (rcond(M) <= eps)  %Increasing lambda did not help    
            error('execution will be terminated due to singular matrix ');
        end
    end;
    dp = M\gradf;           %  dp = inv(M)*gradf;
    ndp = norm(dp);
    ndpp = ndp;
    %%%Lambda will be increased if step size is larger than delta_trust
    while (ndp > delta_trust)
        [L U] = lu(M);
        q = L\dp;           % q=inv(L)*dp;
        lambda = lambda+(ndp^2/norm(q)^2)*(gamma*ndp-delta_trust)/delta_trust;
        M = H+lambda*eye(m);
        dp = M\gradf;       % dp = inv(M)*gradf;
        ndp = norm(dp);
    end
    
    pnew = p - dp';
    rnew = feval(f,pnew,varargin{:});
    f1 = .5*norm(rnew)^2;
    F = f0-dp'*J'*r+.5*dp'*H*dp;    %Taylor expansion of norm(r) close to p
    
    if (f1 < f0) %everything goes as planned, the function is decreasing
        if (f0-F == 0) 
            check_trust = 1;
        else
            check_trust = (f0-f1)/(f0-F);
        end
        if (check_trust < .9 && check_trust > .2 && delta_trust > ndpp)  %The function is well behaved
            delta_trust = delta_trust;      
        elseif (check_trust <= .2 )                                    %Delta_trust will be decreased 
            delta_trust = ndpp/2; 
            continue;
        else
            if delta_trust < 2000
                delta_trust = delta_trust*2;
            else 
                delta_trust = delta_trust;    
            end    
        end
    else                %Then we enter linesearch-backtracking
        [pnew,f1,check] = GheCalibrate_Linesearch(m,p,f0,gradf,-dp,norm(dp),f,varargin{:});
        pnew = pnew(:)';
        rnew = feval(f,pnew,varargin{:});
        delta_trust = norm(pnew-p)+ndpp;
    end
    p = pnew;
    r = rnew(:);
    fprintf('|'); %print a bar for each iteration
    %h = sprintf(['        ' num2str(iter) '                  ' num2str(2*f1)  '             ' num2str(norm(dp))]);
    %disp(h);
end %while
fprintf(' complete \n');
param = p;
resnorm = norm(r)^2;
end