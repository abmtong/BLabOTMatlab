function eldata = readElro_one(infp, inf)

if nargin < 1
    [f, p] = uigetfile('*.txt');
    if ~p
        return
    end
    infp = fullfile(p, f);
end

[p, f, e] = fileparts(infp);
if strcmp(e, '.mat')
    l = load(infp);
    eldata = l.eldata;
    return
end

sT = tic;
fid = fopen(fullfile(p, [f e]));
%Read file: comments are marked by #
rawdat = textscan(fid, '%f %f %f %f %f', 'CommentStyle', '#');
fclose(fid);

%read .inf file, which has info on framerate/etc.
if nargin < 2
    fidi = fopen(fullfile(p, [f '.inf']));
    %This isn't what I'd call a "necessary" file, so don't fret if we don't have it
    if fidi > 0
        rawinf = textscan(fidi, '%s = %s', 'Whitespace', '\t');
        rawinf = [rawinf{:}]; %cell, 14x2
        fclose(fidi);
        inf = [];
        for i = 1:size(rawinf,1)
            fn = rawinf{i,1};
            %make it a viable fieldname: remove space, ()
            fn(fn ==' ' | fn == '(' | fn == ')') = [];
            dt = rawinf{i,2};
            %check if this is a double, if so, convert
            dtdb = str2double(dt);
            if isnan(dtdb)
                inf.(fn) = dt;
            else
                inf.(fn) = dtdb;
            end
        end
    else
        %Check if a .log file exists
        fidi = fopen(fullfile(p, 'log.txt'));
        if fidi > 0 %if so, load the inf from that. Code taken from readElro
            lg = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s', 'WhiteSpace', '\t');
            fclose(fidi);
            lg=[lg{:}];
            
            %get first row (column headers), process into valid fieldnames
            fns = lg(1,:);
            lg = lg(2:end,:);
            for i = 1:length(fns)
                fn = fns{i};
                %remove space and parens
                fn(fn==' ' | fn == '(' | fn == ')') = [];
                fns{i} = fn;
            end
            
            %for rows that are numbers, convert to numbers
            numcols = [4 5 6 10 11 13]; %FPS, Frames, Lost, SoftStarts, FGFreq, Gain
            for i = 1:length(numcols)
                lg(:,numcols(i)) = cellfun(@str2double, lg(:,numcols(i)) , 'Un', 0);
            end
            
            lg(:,1) = cellfun(@(x) [x(1:end-4) '.txt'], lg(:,1), 'Uni',0);
            
            %find right one
            i = find(strcmp(lg(:,1), [f e]), 1, 'last');
            
            %format inf part
            strcel = [fns ;lg(i,:)];
            inf = struct(strcel{:});
        else
            %if don't have .inf, just assume some things
            fprintf('No inf/log for %s, assuming 4k fps\n', f)
            inf = [];
            inf.FramerateHz = 4000;
            inf.SoftStarts = 0;
            inf.Filename = [f e];
            inf.hasinf = 0;
        end
    end
end
eldata = [];
eldata.inf = inf;
%Sometimes the length of the data isn't the same? so force it
lens = cellfun(@length, rawdat);
len = min(lens);
if ~all(len == lens)
    fprintf('Data lengths in %s uneven, trimmed up to %d point\n', f, max(lens)-len);
end

%Convert rawdat to rows, frames to time
eldata.time = rawdat{1}(1:len)' / eldata.inf.FramerateHz;
eldata.x = rawdat{2}(1:len)';
eldata.y = rawdat{3}(1:len)';
eldata.rot = rawdat{4}(1:len)';
eldata.rotlong = rawdat{5}(1:len)';

%Check if there's a _protocol.txt file
fidp = fopen(fullfile(p, [f '_protocol.txt']));
if fidp > 0
    prot = textscan(fidp, '%f %f');
    fclose(fidp);
    prot = [prot{1} prot{2}];
    [~, si] = sort(prot(:,1));
    prot = prot(si, :);
    eldata.prot = prot;
end
%Check if there's a _protocol.dat file
fidd = fopen(fullfile(p, [f '_protocol.dat']));
if fidd > 0
    %Stored as a nx3 matrix with rows time | velocity | position
    tmp = fread(fidd, Inf, 'double', 0, 'b' );
    fclose(fidd);
    tmp = reshape(tmp, [], 3);
    eldata.protfull = tmp;
end

eldata.timestamp = datestr(now, 'yy/mm/dd HH:MM:SS');

save(fullfile(p, [f '.mat']), 'eldata')

%Try loading, just to be sure
isdone = 0;
tries = 0;
while ~isdone
    try
        tmp = load(fullfile(p, [f '.mat']), 'eldata'); %#ok<NASGU>
        isdone = 1;
    catch
        save(fullfile(p, [f '.mat']), 'eldata')
    end
    tries = tries + 1;
    if tries > 10
        warning('File %s might not be saved properly.');
    end
end

%get file sizes
wh = whos('eldata');
by = wh.bytes;
dr = dir(fullfile(p ,[f e]));
by2 = dr.bytes;
if isfield(inf, 'Frame') && isnumeric(inf.Frame)
    fprintf('File %s processed in %0.1fs, filesize %04.1fMB (was %04.1fMB, %02.0f%%) (%06d/%06d frames, %02.0f%%)\n', f, toc(sT), by/2^20, by2/2^20, by/by2*100, len, inf.Frame, len/inf.Frame*100 );
    if len/inf.Frame < .90
        warning('Frames seem too few compared to video length, maybe error?')
    end
    if len/inf.Frame >1
        warning('Frames seem too many compared to video length, maybe error?')
    end
else
    fprintf('File %s processed in %0.1fs, filesize %04.1fMB (was %04.1fMB, %02.0f%%)\n', f, toc(sT), by/2^20, by2/2^20, by/by2*100);
end
%Check if finished by if size difference is "normal"
if by / by2 < .5
    warning('Filesize seems too small compared to original, maybe error\n')
end


