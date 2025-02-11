function out = hmmtest(varargin)
%downsample and HMM fit


%Filtering: 25kHz data, Fc ~ 5kHz maybe, so let's use something ~2.5kHz
wid = 5;
dsamp = 11;

inx = varargin;

%downsample
xf = cellfun(@(x) windowFilter(@median, x, wid, dsamp), inx, 'Un', 0);

%create figure
figure, hold on, ax = gca;

len = length(inx);
%we want to use HMM with some criterion for n_states
for i = 1:len
    tmp = statehmm_findn(inext{i});
    

end