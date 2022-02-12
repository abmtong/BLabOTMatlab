function out = checkOffsetsBPD(inp)

if nargin < 1
    inp = uigetdir;
    if ~inp
        return
    end
end

dr = dir(fullfile(inp, '*.dat'));

dr = dr(~[dr.isdir]);

fs = {dr.name};

%Load offsets
len = length(fs);
outraw = cell(1,len);
axo = zeros(1,len);
bxo = zeros(1,len);
t = cell(1,len);
for i = 1:len
    tmp = readDat(fullfile(inp, fs{i}), 1, 8, 'double', 1);
    tmp = tmp(:,1:(end/2)); %drop the std data
    outraw{i} = tmp;
    axo(i) = tmp(3,1);
    bxo(i) = tmp(4,1);
    t{i} = fs{i}(1:6);
end

figure, hold on, plot(axo), plot(bxo)


%Split by date, plot violin/box/whatever

%Assume same year...




