function out = inputdlg_choosestr(instr)
%Pops a window to choose from a set of strings
% e.g. for picking an arbitrary subset from a list of filenames

%Sanity check: Let's max at 50
len = length(instr);
if len > 50
    warning('Can''t choose more than 50 strings, returning all')
    out = instr;
end

%Format strings for inputdlg
def = cellfun(@(x) sprintf('''%s'' \n', x), instr, 'Un', 0); %Add '' and a trailing space for eval later...
def = {[ def{:} ] };

%Create inputdlg box
idl = inputdlg( 'Choose Items (delete to skip)', '', [length(instr)+1, 100], def );
%If cancel is hit, exit
if isempty(idl)
    out = [];
    return
end
idl = idl{1};

%idl is a char array, so extract the string from each row

%Split into lines
idl = mat2cell( idl, ones(1,size(idl, 1)), size(idl, 2) );
%Remove all blank lines = all spaces
idl( cellfun(@(x) all(x == ' '), idl) ) = [];
%Find first and last apostrophe
aps = cellfun(@(x) strfind(x, ''''), idl, 'Un', 0);
%Get string between edge apostrophes
idl = cellfun(@(x,y) x(y(1)+1:y(end)-1), idl, aps, 'Un', 0);

%Make row vector
out = idl';