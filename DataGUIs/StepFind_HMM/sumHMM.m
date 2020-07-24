function outa = sumHMM(nitermax, files, path)

% [files, path] = uigetfile('C:\Data\pHMM*.mat','MultiSelect','on');
if nargin < 2
    [files, path] = uigetfile('C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB\Testing\GUIDesign\StepFind_HMM\pHMM*.mat','MultiSelect','on');
end
%Check to make sure files were selected
if ~path
    return
end
if ~iscell(files)
    files = {files};
end

if nargin<1
    nitermax = -1; %-= use hmmfinished
end

len = length(files);
% outa = zeros(1,150);
% outa = zeros(1,251);
sumn = 0;
figure name sumHMM
hold on

firsta = 1;
for i = 1:len
    fcdata = load([path filesep files{i}], 'fcdata');
    fcdata = fcdata.fcdata;
    if ~isfield(fcdata, 'hmm')
        continue;
    end
    hmm = fcdata.hmm;
    if isempty(hmm)
        continue
    end
    
    if nitermax < 1 %use hmmfinished
        %check for hmmfinished
        ifin = fcdata.hmmfinished;
        if ifin > 0
            imx = ifin;
        else %still processing, choose latest iter
            imx = length(fcdata.hmm);
            if imx == 0
                return
            end
        end
    else
        imx = nitermax;
    end
    
    niter = length(fcdata.hmm);
    useiter = min(imx, niter);
    
    cropa = hmm(useiter).a;
    
    %find zero
    if firsta
        [~, zind] = max(cropa);
    end
    
    cropa(zind) = 0;
    
    %remove nostep, to normalize for trace speed
    cropa(zind) = 0;
    cropa = cropa/sum(cropa);
    %comment between comments to not do this
    if firsta
        outa = cropa;
        firsta = 0;
    else
        outa = outa + cropa * (length(fcdata.con)-1);
    end
    sumn = sumn + (length(fcdata.con)-1);
    plot(0.1 * ((1:length(cropa))-zind), cropa, 'Color', rand(1,3)/2+[.5 .5 .5])
end

outa = outa / sum(outa);

%nostep removed
% plot(0.1 * (1:length(cropa)), outa, 'LineWidth', 2, 'Color',[0 0 0]), xlim([0 10])
%nostep not removed
plot(0.1 * ((1:length(cropa))-zind), outa, 'LineWidth', 2, 'Color',[0 0 0])
% ta = sort(outa);
% ylim([0 ta(end-1)]);


