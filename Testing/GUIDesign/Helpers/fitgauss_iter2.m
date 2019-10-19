function [fits , gauss] = fitgauss_iter2(inx, iny, sdrange, n, verbose)
%Fits a series of gaussians sequenitally using @fitgauss_iter to a dataset
% that is, instead of fitting gaussians at once, fits one, subtracts it, fits the next, etc.
% So this should let you fit the most prominent peaks sequentially

%Made because I think in stepfinding, there is some minimum step size you can detect
% this means the small histogram is skewed
%So on a long-right tail 2.5 you get a peak at 2.5, 5, 7.5; as well as 3.6 and 6, where the small steps
% missed by the algorithm are addded onto 2.5 and 5 steps (respectively).
%Super emprical but seems "reasonable"? Is the offset knowable?
% Seems to be about 1, meaning the missing steps are ~1bp in size. ...Can I add this back in?


if nargin < 5
    verbose = 0;
end

if nargin < 4
    n = 5; %max peaks to fit
end

if nargin < 3
    sdrange = [-2 2];
end

if verbose
    figure, plot(inx, iny), hold on
end

fits = cell(1,n);
inys = [{iny} cell(1,n)];
for i = 1:n
    try
        [fits{i}, gauss] = fitgauss_iter(inx, inys{i}, sdrange);
    catch
        fits(i:end) = [];
        if i == 1
            %if  i = 1, no fit
            gauss = [];
        end
        
        break
    end
    inys{i+1} = inys{i} - gauss(fits{i}, inx);
    if verbose
        plot(inx, gauss(fits{i}, inx))
        plot(inx, inys{i+1});
    end
end

fitm = reshape([fits{:}], 3, [])';


if verbose == 2
    newy = zeros(size(inx));
    for i = 1:n
        tfit = fitm(i,:);
        if ~mod(i,2)
            tfit(1) = 2*(tfit(1) - fitm(i-1,1));
            %when these steps get missed, they get cut in half then added to larger steps
            % So the actual step size should be 2 * the difference
        end
        newy = newy + gauss(tfit, inx);
    end
    fitgauss_iter2(inx, newy, sdrange, n, 1)
end