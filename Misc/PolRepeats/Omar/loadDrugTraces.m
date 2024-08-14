function out = loadDrugTraces(inp, cropmeth)
%Plot the traces. Use crop as positions for shunt openings

% Use crop 1 as shunt 1 opening, crop 2 as shunt 2 opening
%Just align to shunt 2 opening

if nargin < 1 || isempty(inp)
    inp = uigetdir();
    if ~inp
        return
    end
end

if nargin < 2
    cropmeth = 1; %Crops designate shunt opening, so take crop(2):end 
    %Use =2 for normal crop(1):crop(2)
end


fil = 100; %Filter by this amount
frcmin = 5; %Crop tether breaks

d = dir( fullfile(inp, 'Phage*.mat'));
f = d( ~[d.isdir] );
f = {f.name};

len = length(f);
% fg = figure( 'Name', 'PlotDrugTraces');
% ax = gca;
% hold on

vels = nan(1,len);
outraw = cell(1,len);
frcs = zeros(1,len);
for i = 1:len
    sd = load( fullfile(inp, f{i}) );
    sd = sd.stepdata;
    
    %Load
    tim = sd.time{1};
    con = sd.contour{1};
    frc = sd.force{1};
    
    %Crop force = breaks
    ki = find(frc > frcmin, 1, 'last');
    tim = tim(1:ki-10);
    con = con(1:ki-10);
    frc = frc(1:ki-10);
    
    conraw = sd.contour{1};
    
    %Filter
    tim = windowFilter(@mean, tim, [], fil);
    con = windowFilter(@mean, con, [], fil);
    
    %Load crop for alignment
    cr = loadCrop('', inp, f{i});
    if isempty(cr)
        continue
    end
    
    if cropmeth == 1
        %Shift data. Maybe just crop instead?
        tim = tim-cr(2);
        ki = find(tim>=0, 1, 'first');
        conraw = conraw -con(ki);
        con = con - con(ki);
        
    elseif cropmeth == 2
%         %Just crop between cr's
        ki = sd.time{1} > cr(1) & sd.time{1} < cr(2);
        ki = ki(1:length(conraw));
        conraw = conraw(ki);
        
    end
    
    
    %Plot
%     plot(tim, con)
    
    %Get rough velocity
%     vels(i) = con(end)/tim(end);
    
    %Save data
    outraw{i} = conraw;
    frcs(i) = median(frc, 'omitnan');
end

% title( sprintf('Drug (N=%d)', length(ax.Children)) )

%Remove empty
ki = ~cellfun(@isempty, outraw);
outraw = outraw( ki );
frcs = frcs(ki);

%Save
[~, f] = fileparts(inp);
out.nam = f;
out.drA = outraw;
out.frc = frcs;