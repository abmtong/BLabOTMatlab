function out = prepForDNAcycPweb2_p2(infp, nlen)
%Part two: takes the output file from the webserver (a *.wig) back into the arm flexibilities

%Webserver *.wig is a text file, with a header line, then outputs for cyc-ity of 50bp chunks
% Let's use the normalized C-score (normalization just scales to make a ref. dataset mean 0, var 1

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.wig');
    if ~p
        return
    end
    infp = fullfile(p, f);
end

if nargin < 2
    nlen = 201;
end

%Read text file
fid = fopen(infp);
%Read first line, which is a header
fgetl(fid);
%Read next lines as '%d %f' = position, cyc-ity
lns = textscan(fid, '%d %f');
fclose(fid);
%pos = lns{1};
scr = lns{2};

% %Strip every 50th score
% out = scr(1:50:end);
% %Reshape to [left, right]
% out = reshape(out, 2, [])';

%Plot 
%Pad start and end
scr2 = reshape([ nan(1,24) scr(:)' nan(1,25)], nlen, []);
converrbar(scr2, 1)
%Plot errorbar
%Add line at 'okay' regions. Or at dyad?
xmid = round(nlen/2);
axis tight
yl = ylim;
line(xmid*[1 1], yl)
line(xmid*[1 1]+147/2, yl)
line(xmid*[1 1]-147/2, yl)
