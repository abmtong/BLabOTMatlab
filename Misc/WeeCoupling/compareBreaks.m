function compareBreaks(inst)

%To judge whether Term lines up, plot kdfs of tether break locs

len = length(inst);
out = cell(1,len);

figure('Name', 'CompBrk')
hold on
for i = 1:len
    %Get data of broken tethers
    dat = inst(i).con( inst(i).tfbreak );
    
    %Lets say break loc = mean of last 100 pts
    brks = cellfun(@(x) mean(x(end-100:end)), dat);
    
    %Convert to kdf
    [out{i}, xx] = kdf(brks, 0.1, 4, [-10 200]);
    plot(xx, out{i})
end
xlabel('Tether break loc (bp)')

legend( {inst.name} )