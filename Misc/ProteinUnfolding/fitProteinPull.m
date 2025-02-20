function out = fitProteinPull(infitfcn, inxg, inx, iny, inlb, inub)
%Fits a pulling cycle. Check code for method variants
%For piecewise fitting, pass cell for first 4 args. This method will handle fitting them together, too
%Pass NaN in inxg to use previous iteration's fit

%infitfcn should probably be something like:
%infitfcn{1} = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) );
%infitfcn{2} = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) + x0(7) .* XWLC(f-x0(5), x0(6),inf)  )

len = length(infitfcn);
nxs = cellfun(@length, inxg, 'Un', 0);
nns = cellfun(@length, inx, 'Un', 0);

%Create segment index
si = cellfun(@(x,y) ones(1, x)*y, nns, num2cell(1:len), 'Un', 0);
si = [si{:}];

ft = [];
optopts = optimoptions('lsqcurvefit', 'Display', 'off');

for i = 1:len
    %Get xg
    xg = inxg{i};
    %Replace NaN with previous values?
    xg(isnan(xg)) = ft( isnan(xg) );
    
    %Trim lb/ub
    lb = inlb(1:nxs{i});
    ub = inub(1:nxs{i});
    
    %Create x/y
    x = [inx{1:i}];
    y = [iny{1:i}];
    
    ft = lsqcurvefit(@(x0,x) fitfcn(x0,x,i,si,infitfcn), xg, x, y, lb, ub, optopts );
end

out = ft;

% %Fit pre-rip to just XWLC. Necessary?
% xg = [opts.dwlcg opts.dwlcc 0 0];%PL (nm), SM (pN), CL (nm), dx, df, PL(protein) CL(protein) <<should probably fix
% lb = [0   0   0   -00 -0 ]; %set ext and frc offsets to 0, but can enable if needed
% ub = [1e3 1e4 inf  00  0 ];
% % fitfcn = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) );
% % dft = lsqcurvefit(fitfcn, xg, f(1:ri),x(1:ri), lb, ub, optopts);
% 
% %Fit post-rip to XWLC+Protein
% xg2 = [dft opts.pwlcg opts.pwlcc];%PL (nm), SM (pN), CL (nm), dx, df, PL(protein) CL(protein) <<should probably fix
% lb2 = [lb 0.1 0 ]; %set ext and frc offsets to 0, but can enable if needed
% ub2 = [ub 2 opts.pwlcc*3];
% fitfcn2 = @(x0,f)( x0(3) * XWLC(f-x0(5), x0(1),x0(2)) + x0(4) + ((1:length(f)) > ri ) .* x0(7) .* XWLC(f-x0(5), x0(6),inf)  );
% pft = lsqcurvefit(fitfcn2, xg2, f, x, lb2, ub2, optopts);

end

function y = fitfcn(x0,x,n,s,ff)
%Split x
x = arrayfun(@(ii) x(s==ii), 1:n, 'Un', 0);
%Evaluate fitfcns piecewise
ys = cellfun(@(fh,xx) fh(x0,xx), ff(1:n), x, 'Un', 0);
%Concatenate output
y = [ys{:}];
end