function output = hmm2kv(itermax, ssz)
if nargin < 1
    itermax = 1;
end

if nargin < 2
    ssz = 2.5;
end

[f, p] = uigetfile('C:\Data\pHMM*.mat', 'm', 'on');
if ~p
    return
end
if ~iscell(f)
    f = {f};
end
len = length(f);
outraw = cell(1,len);
out = cell(1,len);
regvit = cell(1,len);
outaraw = cell(1,len);
outa = zeros(1,151);
scor = zeros(1,len);
scora = zeros(1,len);

parfor i = 1:len
    fcdata = load([p f{i}]);
    fcdata = fcdata.fcdata;
    if ~isfield(fcdata, 'hmm') || isempty(fcdata.hmm)
        fprintf('No HMM data.\n')
        continue
    end
    ind = min(itermax, length(fcdata.hmm));
    outraw{i} = fcdata.hmm(ind).fitmle;
    tmp = fcdata.hmm(ind).fit;
    tmp = diff(tmp);
    tmp = tmp(tmp~=0);
    regvit{i} = tmp;
    tmpr = findStepHMMV1b(outraw{i}, struct('sig', ssz), 2); %cheat here: look for 2.5
    tmp = tmpr.fit;
    tmp = diff(tmp);
    tmp = tmp(tmp~=0);
    out{i} = tmp;
    scor(i) = sum(tmp > 2.2 & tmp < 2.8) / length(tmp);
    outaraw{i} = tmpr.a * length(fcdata.con);
    outa = outa + outaraw{i};
    scora(i) = sum(tmpr.a(24:28));
end
outraw = outraw(~cellfun(@isempty, outraw));
scor = scor( ~cellfun(@isempty, out));
scora = scora( ~cellfun(@isempty, out));
outaraw = outaraw( ~cellfun(@isempty, out));
out = out(~cellfun(@isempty, out));
[~,fn]  = fileparts(p(1:end-1)); %get folder name by fileparts and removing ending filesep

figure('Name', sprintf('folder %s, imax %d, ssz %0.2f', fn, itermax, ssz))
histogram([out{:}],1e3, 'EdgeColor','b', 'FaceColor', 'b'), hold on,
histogram([regvit{:}]+.05,1e3, 'EdgeColor','r', 'FaceColor', 'r')

tm = sort(scor);
coff = tm( round(len*.5) );
outclp = out( scor > coff );

figure, histogram([outclp{:}],1e3)

tm = sort(scora);
coffa = tm( round(len*.5) );
outclpa = outaraw( scora > coffa );

outac = mean(reshape( [outclpa{:}], 151, []) , 2);
figure, plot(outa(2:end)), hold on, plot(outac(2:end))

output.aclp = outac;
output.oclp = outclp;
output.o = out;
output.oraw = outraw;
output.a = outa;
output.araw = outaraw;
output.asco = scora;
output.osco = scor;



