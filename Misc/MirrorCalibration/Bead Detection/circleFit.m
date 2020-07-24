function   [xc,yc,r] = circleFit(x,y)
%Fits a circle to coordinates (x, y) [column or row vector], which has center (xc, yc) and radius r
%   [xc yx R] = circfit(x,y)
%
%   fits a circle  in x,y plane in a more accurate
%   (less prone to ill condition )
%  procedure than circfit2 but using more memory
%  x,y are column vector where (x(i),y(i)) is a measured point
%
%  result is center point (yc,xc) and radius R
%  an optional output is the vector of coeficient a
% describing the circle's equation
%
%   x^2+y^2+a(1)*x+a(2)*y+a(3)=0
%
%  By:  Izhak bucher 25/oct /1991, 
   x=x(:); y=y(:);                          %convert to column vector
   a=[x y ones(size(x))]\[-(x.^2+y.^2)];    %solve a(1)x+a(2)x+a(3)+x^2+y^2=0
   %Rewrite the equation of the circle to get its center, radius: (x-a(1)/2)^2 + (y-a(2)/2)^2 = r^2 = -a(3) + (a(1)/2)^2 + (a(2)/2)^2
   xc = -.5*a(1);
   yc = -.5*a(2);
   r  =  sqrt((a(1)^2+a(2)^2)/4-a(3));