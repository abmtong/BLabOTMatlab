function out = deconvtester(iny, sdrange)

if nargin < 2
    sdrange = .5:.5:10; %Range of SDs to try, in units of inx binsize
end

%Try deconv

figure
hold on
xx = 1:length(iny);
hwid = 5; %Half-width to use
for i = 1:length(sdrange)
    %Create convolution filter (gaussian)
    convfil = normpdf( -hwid:hwid, 0, sdrange(i) );
    convfil = convfil / sum(convfil);
    %Deconvolve and pad
    yy = [deconv(iny, convfil), zeros(1, length(convfil)-1)];
    plot(yy);
%     
%     
%     %Model as exp decay
%     convfil = exp(-(0:opts.convdat(2))/opts.convdat(1));
%     %Normalize
%     convfil = convfil / sum(convfil);
%     yy = [ deconv(yy, convfil) zeros(1,length(convfil)-1)]; %Deconv removes length(convfil)-1 points, so re-add them
end

legend( arrayfun(@(x) sprintf( '%0.2f', x) , sdrange, 'Un', 0) );