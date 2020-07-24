function outfn = formath5fn(infn)

outfn = infn;


%{
%remove '/', ' ', and '"' , chars I know show up in fieldnames that are invalid
%Could (should) probably just remove all but A-Z/a-z instead
outfn(outfn == '/' | outfn == ' ' | outfn == '"') = [];
%}

%Remove chars non- A-Z a-z 0-9
nonreg = regexp(outfn, '\W');
outfn(nonreg) = [];

%if empty, just name it dat for now
if isempty(outfn)
    outfn = 'dat';
    warning('fname %s reanmed to dat', infn)
end

%if first char is a number, rename to N[the rest]
if regexp(outfn(1), '\d')
    outfn = ['N' outfn];
end