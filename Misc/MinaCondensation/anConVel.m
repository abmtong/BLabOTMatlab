function outrawy = anConVel(inst, fns, inOpts)
%Can just do vdist_force?


if nargin < 2
    fns = fieldnames(inst);
end


opts.sgp = {1 501};
opts.velmult = -1;
opts.Fs = 1e3;
opts.fbinsz = 500;
opts.tbinsz = 2; %seconds
opts.vbinsz = 10;
opts.sem =  1;
opts.verbose = 0;

if nargin > 2
    opts = handleOpts(opts, inOpts);
end

len = length(fns);
outrawy = cell(1,len);
outrawt = cell(1,len);

for i = 1:len
    %Get data
    dat = inst.(fns{i}).lo;
    
    %Deal with NaN ... somehow
    for j = 1:length(dat)
        %Replace NaN with the previous data value
        isn = find(isnan(dat{j}));
        for k = 1:length(isn)
            dat{j}(isn(k)) = dat{j}(isn(k)-1);
        end
        assert(~any(isnan(dat{j})))
    end
    
    %vdist_force
%     vdist(dat, opts);
    
    outrawy{i} = vdist_force(dat, dat, opts);
    opts2 = opts;
    opts2.fbinsz = opts.tbinsz;
    outrawt{i} = vdist_force(dat, cellfun(@(x) (1:length(x))/opts.Fs, dat, 'Un' , 0) , opts2);
    
%     %Vel, sd, n, fbin, pct paused, fit [0mean 0sd 0pct , vmean vsd vpct]
% out = [vs' vsd' fn' fbinx' pau' fitmat];
    
end

%Plot together
figure('Name', 'anConVel PFV')
hold on
xlabel('Amount compacted')
ylabel('Pause-free velocity(bp/s)')
for i = 1:len
    %Plot velocity-position
    %Convert x to 'amount compacted'
    xx = (6256 - outrawy{i}(:,4))/6256;
    yy = outrawy{i}(:,1);
    ee = outrawy{i}(:,2) ./ sqrt(outrawy{i}(:,3) / opts.sgp{2}  );
    errorbar(xx,yy,ee)
end
legend(fns)
axis tight
xlim([0 1])

%Plot together
figure('Name', 'anConVel Net Vel')
hold on
xlabel('Amount compacted')
ylabel('Net Velocity(bp/s)')
for i = 1:len
    %Plot velocity-position
    %Convert x to 'amount compacted'
    xx = (6256 - outrawy{i}(:,4))/6256;
    yy = outrawy{i}(:,end-1);
    ee = outrawy{i}(:,end) ./ sqrt(outrawy{i}(:,3) / opts.sgp{2} );
    errorbar(xx,yy,ee)
end
legend(fns)
axis tight
xlim([0 1])

%Plot together
figure('Name', 'anConVel PFV')
hold on
xlabel('Time compacting (s)')
ylabel('Pause-free velocity(bp/s)')
for i = 1:len
    %Plot velocity-position
    %Convert x to 'amount compacted'
    xx = outrawt{i}(:,4);
    yy = outrawt{i}(:,1);
    ee = outrawt{i}(:,2) ./ sqrt(outrawt{i}(:,3) / opts.sgp{2}  );
    errorbar(xx,yy,ee)
end
legend(fns)
axis tight
% xlim([0 1])

%Plot together
figure('Name', 'anConVel Net Vel')
hold on
xlabel('Time compacting (s)')
ylabel('Net Velocity(bp/s)')
for i = 1:len
    %Plot velocity-position
    %Convert x to 'amount compacted'
    xx = outrawt{i}(:,4);
    yy = outrawt{i}(:,end-1);
    ee = outrawt{i}(:,end) ./ sqrt(outrawt{i}(:,3) / opts.sgp{2} );
    errorbar(xx,yy,ee)
end
legend(fns)
axis tight
% xlim([0 1])

