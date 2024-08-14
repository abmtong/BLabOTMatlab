function flipOF(inp)

%Flip .mats' extension and contour values in this folder

if nargin < 1
    inp = uigetdir;
end

%Get files in this folder
d = dir(inp);
f = {d(~[d.isdir]).name};

%Create folder \negext
outfol = fullfile(inp, 'negext');
if ~exist(outfol, 'dir')
   mkdir(outfol)
end

for i = 1:length(f)
    %Load file
    sd = load(fullfile(inp, f{i}));
    sd = sd.stepdata;
    %Negate
    sd.extension{1} = -sd.extension{1};
    sd.contour{1} = -sd.contour{1};
    %Save
    stepdata = sd;
    save( fullfile(outfol, f{i}), 'stepdata' );
end