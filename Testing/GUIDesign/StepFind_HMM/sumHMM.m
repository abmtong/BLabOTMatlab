function outa = sumHMM(nitermax)

% [files, path] = uigetfile('C:\Data\pHMM*.mat','MultiSelect','on');
[files, path] = uigetfile('C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB\Testing\GUIDesign\StepFind_HMM\pHMM*.mat','MultiSelect','on');
%Check to make sure files were selected
if ~path
    return
end
if ~iscell(files)
    files = {files};
end

if nargin<1
    nitermax = inf;
end

len = length(files);
outa = zeros(1,150);
% outa = zeros(1,251);
sumn = 0;
figure name sumHMM
hold on

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
    niter = length(fcdata.hmm);
    useiter = min(nitermax, niter);
    
    cropa = hmm(useiter).a;
    %remove nostep, to normalize for trace speed
    cropa = cropa(2:end);
    cropa = cropa/sum(cropa);
    %comment between comments to not do this
    outa = outa + cropa * (length(fcdata.con)-1);
    sumn = sumn + (length(fcdata.con)-1);
    plot(0.1:0.1:15, cropa, 'Color', rand(1,3)/2+[.5 .5 .5])
end

outa = outa / sum(outa);

%nostep removed
plot(0.1:0.1:15, outa, 'LineWidth', 2, 'Color',[0 0 0]), xlim([0 10])
%nostep not removed
% figure, plot(0.1:0.1:25, outa(2:end)), xlim([0 10])

