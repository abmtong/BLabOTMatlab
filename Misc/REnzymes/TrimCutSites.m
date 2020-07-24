function [KeepInd] = TrimCutSites(relist)
%Pass cut sites in cell array, form e.g. 'CGG^ANN'
%Removes nonspecific, blunt, and sites under 3BP

len = length(relist);
KeepInd = 1:len;
for i = len:-1:1
    ln = relist{i};
    %Count recog length - too short, skip
    letters = regexp(ln, '[A-Z]');
    %Check for ^ or (): known cut site
    site = regexp(ln, '[\^(]');
    if length(site) < 1 || length(letters) < 4
        KeepInd(i) = [];
        continue
    end
end