function out = cdf2bar(inax, binsz)
%Converts data stored as CDF to a bar graph (well, not plotted as a bar, but yeah)

if nargin < 2
    binsz = 1;
end

if nargin < 1 || isempty(inax)
    inax = gca;
end

%Get plots
ob = inax.Children;
%Maybe select for only lines... if needed

%Get data
xs = {ob.XData};
ys = {ob.YData};

%Create bins
xmin = min( cellfun(@min, xs) );
xmax = max( cellfun(@max, xs) );

binedges = (floor(xmin/binsz): ceil(xmax/binsz)) * binsz;
bins = binedges(1:end-1)+binsz/2;

%Get heights by interp?
len = length(ys);
ps = cell(1,len);
for i = 1:len
    %Create interp data. Find crossings of bin edeges
    tmpx = [ binedges(1) xs{i} binedges(end) ];
    tmpy = [0 ys{i} 1];
    
    %Uniquify the xdata
    [tmpx, ui] = unique(tmpx);
    tmpy = tmpy(ui);
    
    dat = interp1(tmpx, tmpy, binedges, 'linear') / binsz;
    ps{i} = diff(dat);
    
    %Normalize? Should be with /binsz?
    
    
end

%Copy old axes
fg = figure;
newax = copyobj(inax, fg);
ob = newax.Children;
hold(newax, 'on')
%'Plot' by setting ob data
for i = 1:len
    set(ob(i), 'XData', bins, 'YData', ps{i})
%     
%     tmp = plot(bins, ps{i});
%     
%     %Get... color, Marker, LineStyle
%     tmp.Color = ob{i}.Color;
%     tmp.LineStyle = ob{i}.LineStyle;
%     tmp.Marker = ob{i}.Marker;
%     
%     %Replot, with similar Plot types
%     
end



%Format bins

