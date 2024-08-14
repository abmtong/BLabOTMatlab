function out = procFranp3(inst, rAopts)
%Analyze aligned traces

%Check for crossers
bdys = [558 631 704]-16;
crx = bdys(end);

%Plot sum RTH
fg = figure;
ax = gca; hold on

len = length(inst);
for i = 1:len
    tmp = inst(i);
    
    %Check for crossers
    tfc = cellfun(@(x) sum( x > crx ), tmp.drA);
    tfc = tfc > 100; %If more than say 100pts are above the crossing line, count it as 'crossed'
    inst(i).tfc = tfc;
    
    %Repeat RTH with only crossers
    if all(~tfc)
        rthc = [0 0];
    else
        [hy, hx] = sumNucHist(tmp.drA(tfc), rAopts);
        rthc = [hx(:) hy(:)];
    end
    plot(ax, rthc(:,1), rthc(:,2))
    inst(i).rthc = rthc;
end
legend({inst.nam})

out = inst;

%Crossing time CCDF
tcr = cell(1,len);
%Extract Fsamp from file
for i = 1:len
    %Time from crossing the entry to the exit site
    tmp = cellfun(@(x) find( x >= bdys(3), 1, 'first') - find( x >= bdys(1), 1, 'first'), out(i).drA, 'Un', 0 );
    %Turn empty to NaN to preserve tfpick indexing
    tmp( cellfun(@isempty, tmp) ) = {nan};
    tcr{i} = [tmp{:}]/rAopts.Fs;
    out(i).tcr = tcr{i};
end
%And plot
ccdf = @(x) plot( sort(x(~isnan(x)) ), (length(x(~isnan(x))):-1:1)/length(x(~isnan(x))) );
nams = {inst.nam};
ifcross = cellfun(@any, {inst.tfc});

figure, hold on
cellfun(ccdf, tcr)
legend(nams(ifcross))
set(gca, 'YScale', 'log')
axis tight

