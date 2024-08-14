function [out, outchrg] = aa1to3(inaa)
%Converts a 1-letter code amino acid to 3-letter (e.g. G -> Gly), for ease of forming peptides with LEaP

len = length(inaa);

c3 = {'GLY' 'ALA'    'VAL'    'LEU'    'ILE'    'THR'    'SER'    'MET' 'CYS'    'PRO'    'PHE'    'TYR'    'TRP'    'HIS'    'LYS'    'ARG'    'ASP'   'GLU'    'ASN'    'GLN'};
c1 = 'GAVLITSMCPFYWHKRDENQ';
chrg= zeros(1,20);
chrg([17 18]) = -1; %D E are negative
chrg([15 16]) = 1; %R K are positive. Not H
%Set D, E as neg, K, R as pos

outraw = cell(1, len);
outc = zeros(1,len);
for i = 1:20
    outraw( inaa == c1(i) ) = {[c3{i} ' ']}; %Add a space
    outc( inaa == c1(i) ) = chrg(i);
end

%Concatenate AAs
out = [outraw{:}];
%Sum charges
outchrg = sum(outc);

%OLD VER formatted fancily
%Format so that the 1-letter code is also there. NAH
% outtop = zeros(4, len);
% outtop(2,:) = inaa;
% outtop = char(outtop(:)');
% 
% orn = cellfun(@(x) sprintf( '%03d ', mod(x, 1e3)), num2cell(1:len), 'Un', 0);
% orn = [orn{:}];
% 
% outraw = [outraw{:}];
% 
% out = [ orn; outtop; outraw];

