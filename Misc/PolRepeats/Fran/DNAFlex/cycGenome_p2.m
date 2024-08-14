function [out, outraw] = cycGenome_p2(infp, inst)
%Assembles the output txts of DNAcycP to cyc-ity values for each NPS
%Adds a field to inst (Genome + annotation)

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.txt'); %Grab one file, name %s_cycle_[chr]_[start_bp]
    if ~p
        return
    end
    infp = fullfile(p, f);
end

[p, f, e] = fileparts(infp);

%Strip until first underscore
iuscr = find(f == '_', 1, 'first');
f = f(1:iuscr-1);

fprintf('Grabbing files with name %s_*.txt\n', f)

%Get list of files in this dir
dcpfiles = dir( fullfile(p, [f '*' e]));
dcpfiles = {dcpfiles.name};


len = length(dcpfiles);
rawdat = cell(1,len); %Store cyc-ity
possta = zeros(1,len); %Store start pos
chrnam = cell(1,len); %Store chromosome name
%Import each text
for i = 1:len
    %Read text file
    fid = fopen(fullfile(p, dcpfiles{i}));
    %Read first line, which is a header
    fgetl(fid);
    %Read next lines as [position,cyc-ityNormed,cyc-icity] *Normed = scaled to make Yeast genome distribution Normal
    lns = textscan(fid, '%d,%f,%f');
    fclose(fid);
    %Just take the cyc-ity. NOTE that the first value starts at 25th bp!!!
    rawdat{i} = lns{3}';
    
    %Get metadata from filename
    [~, f, ~] = fileparts(dcpfiles{i});
    uscr = find(f == '_');
    %There should be three _'s
    if length(uscr) == 3
        chrnam{i} = f( uscr(2)+1:uscr(3)-1 );
        possta(i) = str2double( f( uscr(3)+1:end ) );
    else
        error('Improper filename %s, need two _''s', f)
    end
    
end

outraw = {rawdat possta chrnam};

%Assemble genome
nchr = length(inst);
for i = 1:nchr
    %Grab the data from this chromosome. inst.chr must equal chrnam
    ki = strcmp(chrnam, inst(i).chr);
    
    %Create data
    cyc = nan(1, length( inst(i).seq ) );
    
    %Grab data and assemble
    cd = rawdat(ki);
    ci = possta(ki);
    for j = 1:length(cd)
        cyc( ci(j)+23 + (1 : length(cd{j})) ) = cd{j};
%         Manually checked stitching and it seems good
    end
    
    %NaN out non-ATGC seqs. So if our NPS contains this nan, skip
    seq = upper(inst(i).seq);
    isn = seq == 'A' | seq == 'T' |seq == 'G' |seq == 'C';
    cyc(~isn) = nan;
    
    %Assign to inst
    inst(i).cyc = cyc;
    
end
out = inst;
