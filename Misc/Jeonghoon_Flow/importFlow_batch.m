function out = importFlow_batch(inp)
%importFlow on all folders

skipstr = ' NF '; %Skip files with this string in the name
ext = '*.csv'; %File filter for data

if nargin < 1
    inp = uigetdir();
    if ~inp
        return
    end
end

%Get contents
d = dir(inp);

%Strip . and ..
d = d(3:end);

%Only folders
d = d([d.isdir]);
d = {d.name};
len = length(d);

%For each folder...
for i = len:-1:1
    p = fullfile( inp, d{i});
    
    %Get .csvs in folder
    dd = dir( fullfile( p, ext) );
    
    dd = {dd.name};
    %Ignore skipstr
    ki = cellfun(@(x) isempty( strfind(x, skipstr) ), dd);
    dd = dd(ki);
    
    %Run importFlow
    out(i) = importFlow( p, dd );
end















