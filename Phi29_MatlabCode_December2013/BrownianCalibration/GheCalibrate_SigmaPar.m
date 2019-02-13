function s_p = GheCalibrate_SigmaPar(CURVATURE,parameters)
% This function finds the square root of the diagonal elements of the covariance matrix without
% inverting the CURVATURE matrix. This function is derived from 'sigmapar'
% of TweezerCalib2.1
%
% USE: s_p = GheCalibrate_SigmaPar(CURVATURE,parameters)
%
% Gheorghe Chistol, 3 Feb 2012

    if (length(parameters) == 2)
        s_p(1) = CURVATURE(2,2); 
        s_p(2) = [CURVATURE(1,1)];   

    elseif (length(parameters) == 3)
        s_p(1) = det([CURVATURE(2,2) CURVATURE(2,3); CURVATURE(3,2) CURVATURE(3,3)]); 
        s_p(2) = det([CURVATURE(1,1) CURVATURE(1,3); CURVATURE(3,1) CURVATURE(3,3)]);   
        s_p(3) = det([CURVATURE(1,1) CURVATURE(1,2); CURVATURE(2,1) CURVATURE(2,2)]); 

    else
        s_p(1) = det([CURVATURE(2,2) CURVATURE(2,3) CURVATURE(2,4); CURVATURE(3,2) CURVATURE(3,3) CURVATURE(3,4);  CURVATURE(4,2) CURVATURE(4,3) CURVATURE(4,4)]); 
        s_p(2) = det([CURVATURE(1,1) CURVATURE(1,3) CURVATURE(1,4); CURVATURE(3,1) CURVATURE(3,3) CURVATURE(3,4);  CURVATURE(4,1) CURVATURE(4,3) CURVATURE(4,4)]); 
        s_p(3) = det([CURVATURE(1,1) CURVATURE(1,2) CURVATURE(1,4); CURVATURE(2,1) CURVATURE(2,2) CURVATURE(2,4);  CURVATURE(4,1) CURVATURE(4,2) CURVATURE(4,4)]); 
        s_p(4) = det([CURVATURE(1,1) CURVATURE(1,2) CURVATURE(1,3); CURVATURE(2,1) CURVATURE(2,2) CURVATURE(2,3);  CURVATURE(3,1) CURVATURE(3,2) CURVATURE(3,3)]); 
    end

    s_p = sqrt(s_p/det(CURVATURE));
end