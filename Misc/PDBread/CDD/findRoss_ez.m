function out = findRoss_ez(inss, rsd)

%For a sequence of nine seqs, pick the Res that contains it
% For easy manual picking of rosses

ss = reshape([inss.res], 2, [])';

tmp = cell(1, length(rsd));
for i = 1:length(rsd)
    if isnan(rsd(i))
        tmp{i} = [nan nan];
    else
        ki = find( ss(:,1) < rsd(i) & ss(:,2) > rsd(i) , 1, 'first');
        tmp{i} = ss(ki,:);
    end
end

out = struct('rossID', 1, 'ss', {tmp});