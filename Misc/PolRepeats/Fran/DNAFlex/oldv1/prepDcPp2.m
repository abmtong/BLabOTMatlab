function out = prepDcPp2(infp)
%Assembles the output txts of DNAcycP to cyc-ity values for each NPS

if nargin < 1
    [f, p] = uigetfile('*.txt'); %Grab one file, name %s_[mpzb]%d.txt (e.g. HG1_m1.txt)
    infp = fullfile(p, f);
end

[p, f, e] = fileparts(infp);

%Strip until first underscore (remove '_m1')
iuscr = find(f == '_', 1, 'last');
f = f(1:iuscr-1);

fprintf('Grabbing files with name %s_*.txt\n', f)

%Get list of files in this dir
dcpfiles = dir( fullfile(p, [f '*' e]));
dcpfiles = {dcpfiles.name};

%Sort to preserve number order, i.e. 1 2 3 ... instead of 1, 10, 11, ...
% Actually just solve this by changing to %03d...


len = length(dcpfiles);
rawdat = cell(1,len); %Store cyc-ity
rawnfo = zeros(1,len); %Store data type
%Import each text
for i = 1:len
    %Read text file
    fid = fopen(fullfile(p, dcpfiles{i}));
    %Read first line, which is a header
    fgetl(fid);
    %Read next lines as [position,cyc-ityNormed,cyc-icity] *Normed = scaled to make Yeast genome distribution Normal
    lns = textscan(fid, '%d,%f,%f');
    fclose(fid);
    %Just take the cyc-ity, pad front/end with NaN
    rawdat{i} = [nan(1,24) lns{3}' nan(1,25)];
    
    %Convert name to group (-1/0/1/2)
    iuscr = find( dcpfiles{i} == '_', 1, 'last' );
    typchr = dcpfiles{i}( iuscr+1 );
    switch typchr
        case 'm'
            rawnfo(i) = -1;
        case 'z'
            rawnfo(i) = 0;
        case 'p'
            rawnfo(i) = 1;
        case 'b'
            rawnfo(i) = 2;
        otherwise
            error('Invalid gene type: %s is not [mzpb]', typchr)
    end
end

%Group by gene type
out = { [rawdat{rawnfo == -1}]  [rawdat{rawnfo == 0}]  [rawdat{rawnfo == 1}]  [rawdat{rawnfo == 2}] };

%Plot with @plotDcP


