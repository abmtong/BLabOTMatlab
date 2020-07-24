function pwdstruct2hmm(inst)

%infields are: name, time, con

%outfields are: filename, con, force, time, options, 
outpath = uigetdir();
for i = 1:length(inst)
    file = inst(i).name;
    tm = inst(i).time(1);
    outname = sprintf('pHMM%sT%02d.mat', file(6:end), floor(tm*100));
    fcdata = [];
    fcdata.con = inst(i).con;
    fcdata.tim = linspace(inst(i).time(1), inst(i).time(2), length(fcdata.con));
    save([outpath filesep outname], 'fcdata')
end