function processElro(inpf)

if nargin < 1
    [f, p] = uigetfile();
    if ~p
        return
    end
    inpf = fullfile(p, f);
end

dat = readElro(inpf);

%Calculate k by pspec+FRR
caldat = readErot(calpf);
%