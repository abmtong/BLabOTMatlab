function outfps = getfiles(varargin)
%@getfiles takes the same input as @uigetfile, with always MultiSelect (varargin is passed to uigetfile)

[f, p] = uigetfile(varargin{:}, 'MultiSelect', 'on');
if ~p %no files picked -> p==0, do nothing
    outfps = -1;
    return
end
if ~iscell(f)
    f = {f};
end
outfps = cellfun(@(x)[p x], f, 'Un', 0); %'Un' is a shortcut for "UniformOutput" (it's still recognized by inputParser)
