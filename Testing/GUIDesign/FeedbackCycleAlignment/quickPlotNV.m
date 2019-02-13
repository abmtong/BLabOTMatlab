function quickPlotNV(f, p)

if nargin < 2
    [f, p] = uigetfile('E:\011718\*.dat');
    if ~p
        return
    end
end
a = readDat([p f]);
% detectorNames = {'AX' 'BX' 'AY' 'BY'};
% dataInds      = { 3 4 1 2 };
% sumInds       = { 7 8 7 8 };
nax = -a(3,:)./a(7,:);
nbx = a(4,:)./a(8,:);
% nay = -a(1,:)./a(7,:);
% nby = a(2,:)./a(8,:);
mx = a(5,:);
% ext = (nax - nbx)*1000 + mx * 760;
% frc = (nax - nbx)*1000*.4;
% con = ext ./ XWLC(abs(frc), 50, 1000, 4.14);

figure('Name', f)

% %plot mx, ext
% plot(       -[nax'+nbx']*1000/.5 + [mx']*760, 'Color', .8*[1 1 1], 'LineWidth', 1)
% hold on
% plot(smooth(-[nax'+nbx']*1000/.5 + [mx']*760,25), 'Color', 'b', 'LineWidth', 2)
% plot(mx*760)

%plot nv's
plot(nax), hold on, plot(nbx), plot(smooth((nbx + nax)/2,25))

% figure, plot(con)



opts = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt');
xnew = lsqnonlin(@(x) double( sum( (nax - nbx.*x(1) + x(2)).^2 )), [1, .2], [], [], opts);
nax = double(nax);
nbx = double(nbx);
xnew2 = lsqcurvefit(@(x,xd) xd*x(1) + x(2), [1 0], nax, nbx);
fprintf('%0.6f ', xnew, xnew2)
fprintf('\n')
figure, plot(xnew2(1)*nax + xnew2(2)), hold on, plot(nbx), plot(smooth((nax + nbx.*xnew2(1) + xnew2(2))/2,25))

end

