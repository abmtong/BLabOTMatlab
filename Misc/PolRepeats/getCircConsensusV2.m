function [out, yraw, yshift] = getCircConsensusV2(iny, inOpts)
%Get 'circular consensus': best rotation of the inputs so they align the best together
%iny is a cell of 1xn vectors to align
% Do an iterative algorithm: Take average of the vectors, align each to this consensus, repeat until 'convergence'

%v2: Align raw repeats, but every cycle take the cyc average

%Algorithm options
opts.maxrep = 1e3; %Max times to repeat alogrithm
opts.debug = 0; %Plot debug graphs
opts.maxloc = 236; %Location of highest peak
opts.initmeth = 2; %Initialization method: 0: do nothing, 1: randomize, 2: align max
opts.n = 8; %Repeat N

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%Make iny an array of column vectors, so [iny{:}] makes a matrix
iny = cellfun(@(x) x(:), iny, 'Un', 0);
len = length(iny);
yshift = zeros(1,len); %Accumulate circshift deltas here

%If debug, plot update after every cycle
if opts.debug
    fg = figure;
    ax = gca;
    nplot = 5;
    ob = repmat({[]}, 1, nplot);
    hold(ax, 'on')
end

%Randomize offsets, if asked for
switch opts.initmeth
    case 1 %Randomize inputs
        randshift = cellfun(@(x) randi(length(x),1), iny, 'Un',0);
        iny = cellfun(@(x) circshift(x, [y, 0]), iny, randshift, 'Un', 0);
        yshift = yshift + [randshift{:}];
    case 2 %Align to maximum
        [~, maxi] = cellfun(@max, iny, 'un', 0);
        iny = cellfun(@(x,y) circshift(x, [-y 0]), iny, maxi, 'Un', 0);
        yshift = yshift - [maxi{:}];
    case 3 %Align to 'average peak location'
        di = zeros(1,len);
        for i = 1:len
            %Gaussian filter
            tmp = gausmooth(iny{i}, 2);
            %findpeaks
            [pkhei, pkind] = findpeaks(tmp);
            %TBC
        end
    otherwise %or 0: do nothing
        %Do nothing
end


for i = 1:opts.maxrep
%     if i == 1
%         tmpcon = iny{1};
%     else
%         tmpcon = median( [iny{:}], 2 , 'omitnan');
        tmpcon = repmat(median( reshape([iny{:}], [], opts.n*len), 2 , 'omitnan'), [opts.n, 1]);
%     end
    
    %Average them together
%     tmpcon = mean( [iny{:}], 2 , 'omitnan');
%     tmpcon = iny{1};
    %Find rotation of inputs that maximize alignment with this temporary consensus. Convolution does this easily
    for j = 1:len
        %Circular convolution = ifft( fft(a) * fft(b) ). Find max 
        [~, maxi] = max( ifft( abs( fft( tmpcon ) .* fft( iny{j} )) ) );
%         [~, maxi] = max(scr);
        %Rotate this vector to match tmpcon
        iny{j} = circshift( iny{j}, [-(maxi-1) , 0]);
        yshift(j) = yshift(j) - (maxi-1);
    end
    %And repeat. Maybe check for convergence?
    
    %Plot last two 
    if opts.debug
        delete(ob{1});
        ob = [ob(2:end) {plot(ax, tmpcon)}];
        drawnow
        pause(.1)
    end
    
    
end
yraw = iny;
out = median( [iny{:}], 2 , 'omitnan');