function out = pcaDcP(indat)
%Maybe we can pull patterns with @pca?
% Hmm too varied to get anything, it seems

%Input: Cell of NPSes sorted by gene type (output of prepDcPp2)

%bp per NPS
nbp = 301;
%trim to just center N bp?
nfinal = 150;

%Max pca count
npcamax = 30;

%For each gene type...
pcas = cell(1,4);
wts = cell(1,4);
for i = 1:4
    %Get the data
    tmp = indat{i};
    %Reshape to nbp x N
    tmp = reshape(tmp, nbp, []);
    
    %Trim edges (NaNs)
    tmp = tmp(25:end-25,:);
    
    %Trim to center NPS
    tmp = tmp( (1:nfinal) + round((size(tmp,1) - nfinal)/2), : );
    
    %Do PCA
    [pco, ~, pwt] = pca(tmp');
    
    %Choose some component cutoff. Dictate by pwt decay (plot later)
    pcas{i} = pco;
    wts{i} = pwt;
    
    
%     %A lot of these are sin-like, so estimate the frequency?
%     %Crappy estimation, based on sin'' = -(w^2)sin
%     freqguess = zeros(1,nfinal);
%     for j = 1:nfinal
%         freqguess(j) = median( smooth(diff( smooth(diff(pco(:,j)), 10) ),10) ./ pco(2:end-1,j) );
%     end
    
    %Or maybe better with fft?
    % Actually pspec just shows that each component covers sequential regions of freq-space
    %  The major components seem to be in order of lo>hi freq
    
end













