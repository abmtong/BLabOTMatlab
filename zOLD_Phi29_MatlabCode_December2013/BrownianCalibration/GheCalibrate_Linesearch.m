function [x,f,check] = GheCalibrate_Linesearch(n,xold,fold,g,p,stpmax,func,varargin)
% Derived from 'linesearch' of the TweezerCalib2.1 package
%
% xold is the starting point
% fold is the function  value at that point
% g is the gradient at xold
% p is the direction of update
% x1..x? are the nescessary non-fitting parameters for func to be evaluated 
% stpmax is the max steplength provided by the user
% func is the trial function
% 
% x is the new point where f has decreased sufficiently 
% f =func(x)
% check is logical and true when x is too close to xold
%
% USE: [x,f,check] = GheCalibrate_Linesearch(n,xold,fold,g,p,stpmax,func,varargin)
%
% Gheorghe Chistol, 2 Feb 2012

    ALF=1e-14; TOLX=1e-19;
    check=false;

    sum=norm(p);

    if (sum > stpmax) p=p*stpmax/sum; end;

    xold=xold(:);
    g=g(:)'; p=p(:);

    slope=g*p;

    if (slope > 0) 
        pause
        disp('Roundoff problem in  linesearch')
    end
    test=0;

    for i=1:n
        temp=abs(p(i))/max(abs(xold(i)),1);
        if (temp > test) test=temp; end;
    end
    alamin=TOLX/test;

    alam=1;
    MaxIter=1000;
    iter1=0;
    while (check==false && iter1 < MaxIter)
        iter1=iter1+1;
        x=xold+alam*p;
        fev=feval(func,x,varargin{:});
        f=.5*norm(fev).^2;
        if (alam < alamin) x = xold; check = true;
            return
        elseif ( f <= fold+ALF*alam*slope ) return
        else 
            if (alam == 1) tmplam=-slope/(2*(f-fold-slope));
            else
                rhs1=f-fold-alam*slope;
                rhs2=f2-fold-alam2*slope;
                a=(rhs1/alam^2-rhs2/alam2^2)/(alam-alam2);
                b=(-alam2*rhs1*alam^2+alam*rhs2/alam2^2)/(alam-alam2);
                if ( a== 0) tmplam = -slope/(2*b); 
                else disc = b^2 -3*a*slope;
                    if (disc < 0) tmplam = .5*alam;
                    elseif (b<=0) tmplam = (-b+sqrt(disc))/(3*a);
                    else tmplam = -slope/(b+sqrt(disc));
                    end
                end
                if (tmplam > .5*alam) tmplam = .5*alam;
                end
            end
            alam2=alam;
            f2=f;
            alam=max(tmplam,.1*alam);
        end
    end       
end
    
    
