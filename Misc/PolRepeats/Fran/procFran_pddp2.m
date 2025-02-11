function [out, outraw] = procFran_pddp2(inst, opts)
%Analyze the pdd traces

opts.onlycross = 1; %Only crossers?
opts.onlypick = 1; %Only picked traces?

opts.Fs = 800;
opts.fil = 5; %Filter half-width (fil*2+1 bp)
btthr = 1; %Minimum backtrack distance
roi = [558 704]-16; %Only take crossing region

debug = 0; %Debug plot
if debug
    figure Name Debug
    dax = gca;
end

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

len = length(inst);
out = cell(1,len);
outraw = cell(1, len);
%Calculate RTHs from traces fit in p1
for i = 1:len
    %Get data
    tmptr = inst(i).pdd;
    rawtr = inst(i).drA;
    
    %Filter data
    rawtr = cellfun(@(x)windowFilter(@median, x, opts.fil, 1), rawtr, 'Un', 0);
    
    %Crop NaNs = padding to match data pre-roi crop
    rawtr = cellfun(@(x,y) x( ~isnan( y )), rawtr, tmptr, 'Un', 0);
    tmptr = cellfun(@(x) x( ~isnan( x )) , tmptr, 'Un', 0 );
    
    %Select only crossers or only picked
    ki = true(size(tmptr));
    if opts.onlycross
        ki = ki & inst(i).tfc;
    end
    if opts.onlypick
        ki = ki & inst(i).tfpick;
    end
    tmptr = tmptr(ki);
    rawtr = rawtr(ki);
    
    %Kill empty
    rawtr = rawtr( ~cellfun(@isempty, tmptr) );
    tmptr = tmptr( ~cellfun(@isempty, tmptr) );
    
    %Remove backtrakcs from trace
    tmpnobt = cellfun(@(x)removeTrBts(x,1), tmptr, 'Un', 0);
    
    %Find backtracks over btthr
    hei = length(tmptr);
    tmpraw = cell(1,hei);  %Backtrack stats per trace
%     tmpn = zeros(1,hei);
    for j = 1:hei
        %Simplify variables
        tra = tmptr{j};
        nobt = tmpnobt{j};
        raw = rawtr{j};
        
        %Convert to ind/mea
        [in, me] = tra2ind(nobt);
        
        %Crop to roi
        cr = [in( find(me >= roi(1), 1, 'first') ) in( find(me <= roi(2), 1, 'last')+1 )-1];
        tra = tra(cr(1):cr(2)) - roi(1); %Shift to roi(1) == 0
        nobt = nobt(cr(1):cr(2)) - roi(1);
        raw = raw(cr(1):cr(2)) - roi(1);
        [in, me] = tra2ind(nobt);
        
        dw = diff(in);
        
        %Get degree of backtracking = furthest extent - current position
        dx = nobt - tra;
%         dx = nobt - raw;
        %Collect points over the bt threshold
        ki = dx >= btthr;
        %Find steps that these points are in
        btpos = unique(nobt(ki)); %I guess this should work?
        
        %Grab these steps from me
        meki = arrayfun(@(x) find(me == x, 1, 'first'), btpos);
        
        %Grab the durations of these steps
        btdur = dw(meki);
        
        %And the depths
        btdepth = arrayfun(@(x) max(dx( in(x):in(x+1)-1 )), meki);
        
        tmpraw{j} = [btpos(:) btdepth(:) btdur(:)/opts.Fs]; %[position, depth, duration (s)];
        
        if debug
            cla(dax)
            hold(dax, 'on')
            xx = (1:length(nobt)) / opts.Fs;
            plot(dax, xx, raw)
            plot(dax, xx, nobt)
            plot(dax, xx, tra)
            title(sprintf('%d Bts', length(btpos)))
            pause(0.5); %Pause or place a breakpoint
%             foo = 1;
            
        end
        
    end
    %Save raw
    outraw{i} = tmpraw;
    
    %Calculate some stats:
    % Chen paper has: Backtracks per molecule (mean 5.4, median 4.5) , duration (19s 8.4s), position (59nt, 51nt), depth (5.4, 4.5)
    tmp1 = cellfun(@length, tmpraw);
    tmp = cell2mat(tmpraw(:));
    
    %Create a helper function for taking stats
    mnmdsdn = @(x) [mean(x, 1, 'omitnan') median(x, 1, 'omitnan') std(x, 1, 'omitnan') size(x, 1)];
    
    %And take stats, mean/median/sd/n of #backtracks, position, depth, duration
    out{i} = [mnmdsdn(tmp1(:)) mnmdsdn(tmp(:,1)) mnmdsdn(tmp(:,2)) mnmdsdn(tmp(:,3))];
    
end

out = cell2mat(out(:));




% %Plot
% figure('Name', 'procFran_pddp2')
% hold on
% for i = 1:length(inst)
%     plot(inst(i).pddrth(:,1),inst(i).pddrth(:,2))
% end
% legend({inst.nam})
% 
% out = inst;


