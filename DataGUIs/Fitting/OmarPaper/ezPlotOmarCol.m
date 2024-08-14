function ezPlotOmarCol(inst, cropstr)
%Plot traces colored by dwell duration

colg = [.7 .7 .7];
colorder = [0 .2 .4 .6 .8]; %Colors (hue) of each state, hsv? Red/Yellow/Green/Cyan/Blue/Purple [Five colors]

% col = []; %Color
numtra = 1; %Number trace by index
Fs = 1e3; %Fsamp
dt = 0; %Time shift per trace
fil = 0; 

if nargin < 2
    cropstr = 'crop';
end

inst = inst(1);

len = length(inst.drA);
figure Name ezPlotOmar
hold on

%Get exp
ft = inst.(['exp' cropstr])(1,:); %Fit is held under 'exp[cropstr]' field, ignore CIs
ft = reshape(ft, 2, []);
kmax = size(ft, 2);

%Create weighting function to get which exp it comes from
% Basically, for a given dwell time, calculate the probability it came from each mode (= pdf)
% And let's take the mode #-weighted average (i.e. sum( P(came from k_i) * i ))
exppdf = @(x) ft(1,:).* ft(2,:) .* exp( -x(1) .* ft(2,:)) ; %Calculate pdf at this pt, i.e. a k exp(-kx)
% Then (in loop) normalize and calculate 'average state'
% only works on scalars, loop for arrays
normdot = @(x,y) sum( x.*y ) / sum(x);
%And so this is our final weighting function
wgt = @(x) normdot( exppdf(x) , 1:kmax );

outraw = cell(1,len);
for i = 1:len
    dat = double(inst.drA{i});
    tra = inst.pdd{i};
    
    %Crop, if asked
    if ~isempty(cropstr)
        %Crop if it exists
        if isfield(inst, cropstr) && ~isempty(inst.(cropstr)) && ~isempty(inst.(cropstr){i})
            dat = dat(inst.(cropstr){i}(1):inst.(cropstr){i}(2));
            tra = tra(inst.(cropstr){i}(1):inst.(cropstr){i}(2));
        else
            %If there's no crop, skip
            continue
        end
    end
    
    %Filter data
    dat = windowFilter(@median, dat, fil, 1);
    
    
    %Zero
    dat = dat - tra(1) + 1;
    tra = tra - tra(1) + 1;
    
    %Create x
    xx = (1:length(dat)) / Fs + (i-1)*dt;
    
    %Plot data in grey
    plot( xx , dat, 'Color', colg);
    
    %Calculate weightings
    [ind , mea] = tra2ind(tra);
    dw = diff(ind) / Fs;
    mea2 = arrayfun(wgt, dw);
    
    %Make staircase coordinates:
    %X-coords are ind(1 2 2 3 3 4 4 5 5 ... end)
    xs = [ind(1:end-1) ; ind(2:end)];
    xs = xs(:)';
    %Y-coords are mea(1 1 2 2 3 3 4 4 ... end end)
    ys = [mea; mea];
    ys = ys(:)';
    %Cols are like mea but different value
    cs = [mea2; mea2];
    cs = cs(:)';
    %And plot as surface so we can color it
    surface(xx([xs; xs]), [ys; ys], zeros(2, length(xs)), [cs; cs], 'EdgeColor', 'interp', 'LineWidth', 1)
    
    if numtra
        text(xx(end), dat(end), sprintf('%d', i))
    end
    
    outraw{i} = mea2;
end
%Fix axis
axis tight
axis manual

%Set colors

%Create HSV curve: get the values and interp in between
colhsv = interp1(1:kmax, colorder(1:kmax), linspace(1, kmax, 64));
cols = arrayfun(@(x) hsv2rgb([mod(x,1), 1, 1]), colhsv, 'Un', 0);
cols = [cols{:}];
cols = reshape(cols, 3, [])';
colormap(cols);

set(gca, 'CLim', [1 kmax])
colorbar

xlabel('Time (s)')
ylabel('Contour (bp)')

%Plot stacked bar of a_i's

bx = 1:len;
by = zeros(len, kmax);
for i = 1:len
    tmp = arrayfun(@(x) sum( round(outraw{i}) == x ), 1:kmax );
    by(i,:) = tmp / sum(tmp);
end

figure, bar(bx, by, 'stacked')
colormap(cols); %Stacked bar is handled by colormap, I guess?
colorbar
set(gca, 'CLim', [1 kmax])
ylim([0 1])
xlabel('Trace number')
ylabel('Step Proportion')















