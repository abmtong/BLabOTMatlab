function plotNMu_xaxis(ax)

if nargin < 1
    ax = gca;
end

%Turn labels in ax to codons
set(ax, 'XTickLabelMode', 'auto')
xtl = get(ax, 'XTickLabels');


%Make into numbers
nn = str2double(xtl);

nt = 'ATGC';

%For each...
for i = 1:length(nn)
    n = nn(i);
    %If integer, convert to codon
    if ~mod(n,1)
        xtl{i} = nt(num2cdn(n));
    else %Else, null
        xtl{i} =  '';
    end
end

set(ax, 'XTickLabels', xtl);