function out = kalman(tr, inModel)
%filters a trace using kalman filtering
%Used like HMM, takes many of the same params (input is same inModel)


if nargin < 1
    sd = 4;
    tr = [zeros(1,100) ones(1,100)*2.5 ones(1,100)*5 ones(1,100)*7.5 ones(1,100)*8.6];
    tr = tr + sd*randn(1,length(tr));
end

if nargin < 2
    inModel = [];
end

if ~isfield(inModel, 'sig')
    sig = estimateNoise(tr, [], 2);
    inModel.sig = sig;
else
    sig = inModel.sig;
end

%Theory requries gaussian a: for now try based on that
ame = 2.5;
asd = 1;

len = length(tr);

%set priors
m=0;
p=0;

for i = 1:len
    
    
    
end














