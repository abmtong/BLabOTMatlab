function ezPlotOmar(inst, cropstr)

% col = []; %Color
numtra = 1; %Number trace by index
Fs = 1e3; %Fsamp
dt = 0; %Time shift per trace

if nargin < 2
    cropstr = 'crop';
end

inst = inst(1);

spds = [25 5 .5];

len = length(inst.drA);
figure Name ezPlotOmar
hold on

for i = 1:len
    dat = double(inst.drA{i});
    
    %Crop, if asked
    if ~isempty(cropstr)
        %Crop if it exists
        if isfield(inst, cropstr) && ~isempty(inst.(cropstr)) && ~isempty(inst.(cropstr){i})
            dat = dat(inst.(cropstr){i}(1):inst.(cropstr){i}(2));
        else
            %If there's no crop, skip
            continue
        end
    end
    
    %Filter and plot
    dat = windowFilter(@median, dat, 10, 1);
    
    %Zero
    dat = dat - dat(10);
    xx = (1:length(dat)) / Fs + (i-1)*dt;
    plot( xx , dat);
    
    if numtra
        text(xx(end), dat(end), sprintf('%d', i))
    end
    
end
%Fix axis
axis tight
axis manual

rgb = 'rgb';
xl = xlim;
for i = 1:length(spds)
    plot(xl, xl * spds(i), rgb(i))
end

xlabel('Time (s)')
ylabel('Contour (bp)')

