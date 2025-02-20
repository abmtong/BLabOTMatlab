function out = RPcheck_drift(inst, wid)

if nargin < 2
    wid = 300; %Choose a N_pts where it shouldn't be unfolded yet; something ~ 2*opts.wid(1) for RPp3b is probs good
end

%Check for drift/noise pull-to-pull by looking for... procon wid pts before inst.ripind

% %If these were from multiple files, separate
% if isfield(inst, 'file')
%     nams = {inst.file};
%     [uu, ~, ic] = unique(nams);
% else
%     uu = {''};
%     ic = ones(1, length(inst));
% end


tc = {inst.conpro};
tr = {inst.ripind};
prerip = cellfun(@(x,y) median(x(y-2*wid:y-wid)), tc, tr);
posrip = cellfun(@(x,y) median(x(y+wid:y+2*wid)), tc, tr);

figure, plot(prerip), hold on, plot(posrip), plot(posrip-prerip)

sds = [std(prerip), std(posrip), std(posrip-prerip)];

legend( cellfun(@(x,y)sprintf( '%s, sd=%0.2f',x, y), {'prerip' 'postrip' 'post-pre'} , num2cell(sds), 'Un', 0 ) );

%Highlight outliers?
%Lets put Z-score cutoff as ... two more than? regular cutoff (as in, Z such that normcdf(Z) = 1-1/x)
