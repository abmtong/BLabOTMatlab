function out = fitRise_plotStats(infr)
%inst = output of fitRise

%Get FitRise fit and calculate some values:
% Background = height of pre-fit line
% Signal height = end of fit line

len = length(infr);
outb = nan(2,len); %R and G
outh = nan(2,len); %R and G

for i = 1:len
    for j = 1:2
        tmp = infr(i).frraw{j};
        %Some might be empty (failed fit), just skip these with try-catch
        if isempty(tmp)
            continue
        end
        
        tmp = tmp{2};
        outb(j, i) = tmp(1);
        outh(j, i) = tmp(end);
    end
end

out = [outb; outh];