function out = plotDrugTraces(inst, nplot)
%Plot the traces. Use crop as positions for shunt openings

% Use crop 1 as shunt 1 opening, crop 2 as shunt 2 opening
%Just align to shunt 2 opening

if nargin < 2
    nplot = inf;
end

fil = 100; %Filter by this amount
Fs = 1e3;
endcrop = 0; %Crop by this much before end
cols = lines(7);
cmod = @(x) mod(x-1, length(cols) )+1;

len = length(inst);
fg = figure( 'Name', 'PlotDrugTraces');
ax = gca;
hold on

%Start with some junk plots, for legend coloring
arrayfun(@(x) plot(0,0), 1:len)
legend({inst.nam})

for i = 1:len
    dat = inst(i).drA;
    tra = inst(i).pdd;
    
    %Filter
    datF = cellfun(@(x)windowFilter(@mean, x, [], fil), dat, 'Un', 0);
    traF = cellfun(@(x)windowFilter(@mean, x, [], fil), tra, 'Un', 0);
    
    %Crop to zero
    traF = cellfun(@(x,y) y( find( x > 0 , 1, 'first'):end ),datF, traF, 'Un', 0);
    datF = cellfun(@(x) x( find( x > 0 , 1, 'first'):end ), datF, 'Un', 0);
    
    
    %Crop end
    if endcrop > 0
        datF = cellfun(@(x,y) x( 1: find(y <= (max(y)-endcrop), 1, 'last') ), datF, traF, 'Un', 0 );
    end
    
    
    %Choose subset
    hei = length(datF);
    nm = min( hei, nplot );
    datF = datF(randperm(hei, nm));
    
    %Plot
    cellfun(@(x) plot( (1:length(x))/Fs*fil, x, 'Color', cols(cmod(i),:) ), datF) 
end

xlabel('Time (s)')
ylabel('Contour (bp)')




