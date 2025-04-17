function RPPlotTraces(inst, spc, xwlcspc)
%Plots traces with spacing spc. Adds xwlc fit with spacing xwlcspc between the lines (protein unfolded)

fil = 10; %Filter amount

%Colors
cols = { [0 0 1] [1 0 0] }; %Pull color, retract color

if nargin < 2 || isempty(spc)
    spc = 100;
end

if nargin < 3 || isempty(xwlcspc)
    xwlcspc = [0 20 50];
end

len = length(inst);
fcr = 3; %Space by crossing pt. of pull with this force

%Create figure
figure Name RPPlotTraces, hold on

for i = 1:len
    %Get data, split pull/retract
    xf1 = windowFilter(@median, inst(i).ext(1:inst(i).retind), [], fil);
    yf1 = windowFilter(@median, inst(i).frc(1:inst(i).retind), [], fil);
    
    xf2 = windowFilter(@median, inst(i).ext(inst(i).retind+1:end), [], fil);
    yf2 = windowFilter(@median, inst(i).frc(inst(i).retind+1:end), [], fil);
    
    %Get crossing of fcr
    xoff = xf1( find(yf1 > fcr, 1 ,'first') );
    
    if i == 1
        %Plot xwlcspc lines
        xwlcft = inst(i).xwlcft;
        ywff = linspace( min(yf1), max(yf1), 100 );
        xwff = xwlcft(3) * XWLC(ywff, xwlcft(1), xwlcft(2) );
        for j = 1:length(xwlcspc)
            plot( xwff + xwlcspc(j) * XWLC(ywff, xwlcft(6), inf ) - xoff + spc*i, ywff, 'k--')
        end
    end
    
    %Plot data. For layering, plot ret first
    plot( xf2 - xoff + spc*i, yf2, 'Color', cols{2} )
    plot( xf1 - xoff + spc*i, yf1, 'Color', cols{1} )
    
end

