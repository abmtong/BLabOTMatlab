function out = ppKVv3p4(infg)
%Fits every curve in the figure output of PPKVp2 to a gamma, and outputs the annotated figure + stats to .fig/.xls

if nargin < 1
    infg = gcf;
end

%Get axes and their titles
axs = infg.Children;
tits = cellfun(@(x) x.String, {axs.Title}, 'Un', 0);
len = length(axs);

%Store output here
dat = cell(1,len);

%For each axis...
for i = 1:len
    %Get the lines
    lns = axs(i).Children;
    hei = length(lns);
    tmpd = cell(1,hei);
    %And fit their shape to a distribution:
    for j = 1:hei
        %Get their data
        %Fit to gamma
        x = lns(j).XData;
        y = lns(j).YData;
        c = lns(j).Color;
        %Encode color into hex
        col = dec2hex( uint8( c * 255 ) );
        col = col';
        col = col(:)';
        %Shouldn't have to, but crop to positive x
        ki = x>0;
        x = x(ki);
        y = y(ki);
        %Renormalize y
        y = y / sum(y) / median(diff(x));
        [ft, yg] = fitgamma(x, y);
        %Output is : gammma k, gamma mu, color
        tmpd{hei-j+1} = {ft(1) ft(2) col}; %Fill tmpd in reverse bc Children is in reverse order
        %Add the fit lines in lighter but same color
        plot(axs(i), x, yg, 'Color', mean([c; 1 1 1], 1), 'LineWidth', 2)
    end
    %Regularize dat: Make each row equal length
    if isempty(tmpd)
        dat{i} = repmat({'NA'}, [3,1]);
    else
        dat{i} = [tmpd{:}]';
    end
end

dat = [dat{:}]';
out = flipud([tits' dat]);
nam = infg.Name;
nam = strrep(nam, 'PhagePauseKVv3 ', '');
if isempty(nam)
    nam = 'ppkv';
end
xlswrite(['ppkv_' nam '_p4'], out)
infg.Name = ['PhagePauseKVv3p4 ' nam];
savefig(infg, ['ppkv_' nam '_p4'])