function [out, phipsi] = getMeso(infp, method)
%Calculates and classifies backbone dihedrals ('mesostring') based on the ramachandran plot
% Output uses alpha = 0, beta = 1, left-alpha = 2
% Uses builtin @ramachandran

%Method for classifying phi/psi to alpha/beta/etc. See code
if nargin < 2
    method = 1;
end

%Get angles from builtin
ra = ramachandran(infp, 'Plot', 'none');
phipsi = ra.Angles;
%Rename output struct

len = length(ra.ResidueNum);
out = nan(1, len);
for i = 2:len-1 %Edge aa's won't be defined
    %Classify a/b based on rama angle. Choose method
    switch method
        case 1 %Folding Very Short Peptides method (doi:10.1371/journal.pcbi.0020027)
            %Easiest to see if you just draw it out, but this has basically 9 regions:
            % 7 8 9 ; 4 5 6 ; 1 2 3 [like a numpad]
            % Divided on the x/phi axis at 0 and 120 ; on y/psi axis at -135 and 45
            %  (Same plot as if you called ramachandran() without 'Plot', 'none')
            % For non-gly, Beta = regions 1 3 7 9, Alpha = 4 6, LeftAlpha = 2 5 8
            %  *I think the paper has a typo where reigon 6 is assigned to both a and l
            % For gly, this is a bit different, more like:
            %  7 9; 4 6; 1 3 [2x3 matrix, like a numpad but without the center column]
            % Beta = 7 9 1 3, a = 4, l = 6
            % Division along x/phi is at 0, division along y/psi is at -135, 45 for Phi<0 , at -45, 135 for Phi>0
            
            %Let's define a = 0, b = 1, l = 2
            
            %Get phi, psi angles
            phi = ra.Angles(i,1);
            psi = ra.Angles(i,2);
            
            %Skip NaN
            if isnan(phi) || isnan(psi)
                continue
            end
            
            %Check first for amino acid identity: glycine is handled differently
            % Paper is ambiguous about equals, let's take everything as lo <= x < hi
            if strcmp(ra.ResidueName{i}, 'GLY')
                %Check phi sign
                if phi >= 0
                    if psi >= -45 && psi < 135
                        out(i) = 2;
                    else
                        out(i) = 1;
                    end
                else %Phi < 0
                    if psi >= -135 && psi < 45
                        out(i) = 0;
                    else
                        out(i) = 1;
                    end
                end
                    
            else %Non-gly
                %First check for l, since we just need to check phi
                if phi >= 0 && phi < 120
                    out(i) = 2;
                else %Actually, we just need to check psi now.
                    if psi >= -135 && psi < 45
                        out(i) = 0;
                    else
                        out(i) = 1;
                    end
                end
            end
    end
    
end