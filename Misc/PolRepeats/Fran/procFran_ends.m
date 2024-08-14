function procFran_ends(inst)

opts.tfpick = 1; %Apply tfkeep or not
opts.disp = [558 631 704]-16;



len = length(inst);


leg = {inst.nam};


figure
hold on

getEnd = @(x) mean(x(end-100:end));

for i = 1:len
    if opts.tfpick
        nds = cellfun(getEnd, inst(i).drA(inst(i).tfpick));
    else
        nds = cellfun(getEnd, inst(i).drA);
    end
    
    %Plot as 'o'
    plot(nds, i*ones(size(nds)), 'o')
end

legend(leg)

%Green lines at nuc pos;s
for i = 1:length(opts.disp)
    plot(opts.disp(i) * [1 1], [0 len+1], 'g')
end