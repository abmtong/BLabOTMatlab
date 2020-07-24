function [outa, inst] = sumHMMstruct(inst, nitermax)
%infp is fp or struct

if nargin < 1 || isempty(inst) || isa(inst, 'double')
    % [files, path] = uigetfile('C:\Data\pHMM*.mat','MultiSelect','on');
    [files, path] = uigetfile('C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB\Testing\GUIDesign\StepFind_HMM\pHMM*.mat','MultiSelect','on');
    %Check to make sure files were selected
    if ~path
        return
    end
    if ~iscell(files)
        files = {files};
    end
    len = length(files);
    struct = cell(1,len);
    for i = 1:len
        fcdata = load([path filesep files{i}], 'fcdata');
        fcdata = fcdata.fcdata;
        if ~isfield(fcdata, 'hmm')
            continue;
        end
        struct{i} = fcdata;
        hmm=fcdata.hmm;
        if isempty(hmm)
            continue
        end
    end
    inst = [struct{:}];
end

if nargin<2
    nitermax = inf;
end

len = length(inst);
outa = zeros(1,250);
% outa = zeros(1,251);
sumn = 0;
figure name sumHMM
hold on

for i = 1:len
    fcdata = inst(i);
    hmm = fcdata.hmm;
    if isempty(hmm)
        continue
    end
    niter = fcdata.hmmfinished;
    if niter == 0
        niter = length(hmm);
    end
    useiter = min(nitermax, niter);
    
    cropa = hmm(useiter).a;
    
    %normalize these somehow:
    normtype = 2;
    %0 : just average fcs equally
    %1: remove nostep
    %2: rm nostep and norm by num steps
    %3: dont remove nostep but norm by length
    cropa = cropa(2:end);
    switch normtype
        case 1
            %remove nostep, to normalize for trace speed
            cropa = cropa/sum(cropa);
            plota = cropa;
        case 2
            plota = cropa/sum(cropa);
            cropa = plota * (length(fcdata.con)-1);
        case 3
            plota = cropa * length(fcdata.con)-1;
        otherwise
    end
    if any(isnan(cropa))
        fprintf('skipped file %d\n', i)
        continue
    else
        outa = outa + cropa;
        sumn = sumn + (length(fcdata.con)-1); %length-1 bc there's only this many chances to step)
        plot(0.1:0.1:25, plota, 'Color', rand(1,3)/2+[.5 .5 .5])
    end
end

outa = outa / sum(outa);

%nostep removed
plot(0.1:0.1:25, outa, 'LineWidth', 2, 'Color',[0 0 0]), xlim([0 10])
%nostep not removed
% figure, plot(0.1:0.1:25, outa(2:end)), xlim([0 10])

