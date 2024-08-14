function scaley2h(inax)
%Scales axes from yeast-normalized to human-normalized
%DNAcycP outputs scaled cyclizibility that is normalized to yeast: 0 mean, 1 variance
% **Maybe that's not actually true? My tests give a mean,sd of -.34,.3 for the yeast genome
%   So, the dists of Human and Yeast are from multiple populations, a major peak with mean <0 and sd ~0.3, next biggest at positive mean (appears as a shoulder)
% Let's scale from yeast to some empirically-defined human values
% Human cyc-ity of 100 3e6bp sections was taken, main peak taken as mean/var

if nargin < 1
    inax = gca;
end

%Stats: 
h_mean = -.14;
h_std = 0.27;
%Yeast genome actually looks similar, two-peaked, major peak at -.34, std 0.3
% I would guess the normalization was to both peaks, where the mean,sd is closer to 0,0.5

%Scale y-axis of all curves to make this zero-mean, 1 std

%For everything in that graph...
ch = inax.Children;
len = length(ch);
for i = 1:len
    ob = ch(i);
    %There will be Rectangle, Line, and Patch objects
    switch class(ob)
        case 'matlab.graphics.primitive.Rectangle'
            %Scale Position
            pos = ob.Position;
            pos(2) = (pos(2) - h_mean) / h_std;
            pos(4) = pos(4)/h_std;
            ob.Position = pos;
        case {'matlab.graphics.primitive.Line', 'matlab.graphics.chart.primitive.Line' 'matlab.graphics.primitive.Patch'}
            %Scale YData
            ob.YData = (ob.YData - h_mean) / h_std;
        otherwise
            warning('Class %s not handled, skipping', class(ob))
    end
end