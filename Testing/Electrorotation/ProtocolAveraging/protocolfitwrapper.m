function out= protocolfitwrapper()

[f, p] = uigetfile('*.fig','MultiSelect', 'on');
if ~p
    return
end
if ~iscell(f)
    f={f};
end

len = length(f);

prots = cell(1,len);
raws = cell(1,len);
protfit = cell(1,len);
histfit = cell(1,len);

for i = 1:len
    fg = openfig([p f{i}], 'invisible');
    [prots{i}, raws{i}] = getprotfromfig(fg);
    protfit{i} = protocolfit2( prots{i}{1}*360, prots{i}{2} );
    histfit{i} = protocolfit2( prots{i}{3}, prots{i}{4} );
    close(fg);
end

% out.pfraw = protfit;
% out.hfraw = histfit;

out = protocolfitsort2(protfit, histfit); 



