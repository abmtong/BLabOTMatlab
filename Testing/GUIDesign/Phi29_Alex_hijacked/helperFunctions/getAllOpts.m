function outOpts = getAllOpts(structname)
%Outputs all fieldnames and defaults of an options structure (named 'opts' by default) in the selected m-files.
%Useful to make a default structure containing all available options fields
%Unpareseable fieldnames will be in 'INVALID' field (default could not be fetched)

if nargin < 1
    structname = 'opts';
end
[files, path] = uigetfile('*.m', 'Choose your code files that use the opts struct', 'MultiSelect','on');
if ~iscell(files)
    files = {files};
end
fnames = [];
defaults = [];

%Textscan each file line for assignments to opts
for i = 1:length(files)
    fid = fopen([path files{i}]);
    %Read individual lines
    codeLines = textscan(fid, '%s', 'Whitespace', '', 'Delimiter', '\n', 'CommentStyle', '%');
    codeLines = codeLines{1};
    for j = 1:length(codeLines)
        codeLine = codeLines{j};
        if isempty(codeLine)
            continue
        end
        %Check for comment (@textscan NVP 'CommentStyle' only removes left-most %'s) by checking if first non-space char. is %
        if isequal(textscan(codeLine, '%c', 1), {'%'})
            continue
        end
        %Remove spaces, as 'opts . fn' is a valid alternative to 'opts.fn'
        codeLine(codeLine==' ') = [];
        %Search for statements that contain 'opts.*=', extract matched string
        [st, en] = regexp(codeLine, [structname '.*=']);
        if isempty(st)
            continue
        end
        optsDotFn = codeLine(st(1):en(1)-1); %Should be 'opts.fn'
        %Find '.'
        stFn = regexp(optsDotFn, '[.]');
        %Extract fn from 'opts.fn' to get fieldname
        fn = optsDotFn(stFn+1:end);
        %Need to check existence && ignore dynamic fieldnames
        if ~isempty(fn) && fn(1) ~= '('
            fnames = [fnames {fn}]; %#ok<AGROW>
            %Fetch default value (code after the equals sign, to @eval)
            stDef = regexp(codeLine, '=');
            defaults = [defaults {codeLine(stDef(1)+1:end)}]; %#ok<AGROW>
        end
    end
end

%Keep only first instance of each fieldname
[~, keepind] = unique(fnames);
%Unique sorts fnames, but we want to keep in original order
keepind = sort(keepind);
fnames = fnames(keepind);
defaults = defaults(keepind);

%@eval the defaults to create the structure. Some might not work - hence try/catch, place failed fieldnames in outOpts.INVALID
numInvalid = 0;
eval(sprintf('%s.INVALID = {};', structname));
for i = 1:length(fnames)
    try
        eval(sprintf('%s.%s = %s', structname, fnames{i}, defaults{i}));
    catch
        numInvalid = numInvalid + 1;
        eval(sprintf('%s.INVALID(numInvalid) = fnames(i);', structname));
    end
end
eval(sprintf('outOpts = %s;', structname));
if isempty(outOpts.INVALID) %#ok<NODEF>
    outOpts = rmfield(outOpts, 'INVALID');
end