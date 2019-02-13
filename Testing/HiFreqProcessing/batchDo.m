function batchDo(path, files, fcn, opts)
%Batch-does any fcn(filepath, opts{:}) with MultiSelect

if nargin < 2 || isempty(path) || isempty(files)
    [files, path] = uigetfile('*.*','Multiselect','on');
    if ~path
        return
    end
end

if nargin < 4
    opts = [];
end

if ~iscell(files)
    files = {files};
end

len = length(files);

for i = 1:len
    fcn([path files{i}], opts{:});
end