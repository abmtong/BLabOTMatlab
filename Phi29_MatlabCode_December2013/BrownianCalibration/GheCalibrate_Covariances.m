function covs =  GheCalibrate_Covariances(CURVATURE)
% Covariances expressed as determinant of of elements from inverse matrix.
% This function is derived from COVARIANCES.m in the TweezerCalib2.1
% package.
%
% USE: covs =  GheCalibrate_Covariances(CURVATURE)
%
% Gheorghe Chistol, 3 Feb 2012

    if (size(CURVATURE,1) == 2)
        covs = -CURVATURE(2,1);
    elseif (size(CURVATURE,1) == 3)
        covs(1) = -det([CURVATURE(1,2) CURVATURE(1,3);CURVATURE(3,2) CURVATURE(3,3)]); 
        covs(2) = det([CURVATURE(1,2) CURVATURE(1,3);CURVATURE(2,2) CURVATURE(2,3)]); 
        covs(3) = -det([CURVATURE(1,1) CURVATURE(1,3);CURVATURE(2,1) CURVATURE(2,3)]); 
    else
        covs(1) = -det([CURVATURE(1,2) CURVATURE(1,3) CURVATURE(1,4);CURVATURE(3,2) CURVATURE(3,3) CURVATURE(3,4);CURVATURE(4,2) CURVATURE(4,3) CURVATURE(4,4)]); 
        covs(2) = det([CURVATURE(1,2) CURVATURE(1,3) CURVATURE(1,4);CURVATURE(2,2) CURVATURE(2,3) CURVATURE(2,4);CURVATURE(4,2) CURVATURE(4,3) CURVATURE(4,4)]); 
        covs(3) = -det([CURVATURE(1,1) CURVATURE(1,3) CURVATURE(1,4);CURVATURE(2,1) CURVATURE(2,3) CURVATURE(2,4);CURVATURE(4,1) CURVATURE(4,3) CURVATURE(4,4)]);
        covs(4) = -det([CURVATURE(1,2) CURVATURE(1,3) CURVATURE(1,4);CURVATURE(2,2) CURVATURE(2,3) CURVATURE(2,4);CURVATURE(3,2) CURVATURE(3,3) CURVATURE(3,4)]); 
        covs(5) = det([CURVATURE(1,1) CURVATURE(1,3) CURVATURE(1,4);CURVATURE(2,1) CURVATURE(2,3) CURVATURE(2,4);CURVATURE(3,1) CURVATURE(3,3) CURVATURE(3,4)]);
        covs(6) = -det([CURVATURE(1,1) CURVATURE(1,2) CURVATURE(1,4);CURVATURE(2,1) CURVATURE(2,2) CURVATURE(2,4);CURVATURE(3,1) CURVATURE(3,2) CURVATURE(3,4)]); 
    end

    if (det(CURVATURE) == 0)
        error('execution will be terminated due to singular matrix in mfile COVARIANCES.m at line 18');
    end
    covs = covs/det(CURVATURE);
end