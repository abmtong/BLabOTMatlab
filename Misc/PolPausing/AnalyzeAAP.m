function AnalyzeAAP(dwstruct)
%After doing fitVitterbi already

%For each fieldname in dwstruct, do exp fitting and kn comparisons and save figs

fn = fieldnames(dwstruct);
len = length(fn);
xrng = [1.1e-3 1];

for i = 1:len
    f = fn{i};
    dw = dwstruct.(f);
    %Do fitbiexp
    fitbiexp([dw{:}], xrng, 1, 1);
    %Save figure
    fg = gcf;
    savefig(fg, sprintf('exp_%s.fig', f))
    %Do weescatter
    weescatter(dw, xrng);
    fg = gcf;
    savefig(fg, sprintf('kn_%s.fig', f))
    %Cleanup
%     close all
end