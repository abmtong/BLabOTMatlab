function out = parseRelion(infp)
%unfnished, using builtin text importer for now

if nargin < 1
    [f, p] = uigetfile('*.star');
    infp = fullfile(p, f);
end

fid = fopen(infp);
%clear first lines
fgetl(fid);
fgetl(fid);
fgetl(fid);
fgetl(fid);
while true
    ln = fgetl(fid);
    if ln(1) == '_';
        continue
    end
    ts = textscan('%s ', ln);
    
    
end
