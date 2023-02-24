function [outData, datraw, colnams] = ReadMiniFile_minaV4(infp, tfreconv)
%Reads a minitweezers data file. First output gives you {force, extension, time}, rest are are all the raw values
%V3: Works now with differing file column headers (searches by column name instead of hard-coded column number)
%V4: Force as Y-force and Extension as (A_dist-Y+B_dist-Y)/2

%Usage: Assumes parent folder starts with 6 char of MMDDYY (or some other identifier)

if nargin < 1 || isempty(infp)
    %Grab, load file if not supplied
    [file, path] = uigetfile('.txt');
    infp = fullfile(path, file);
end

if nargin < 2
    tfreconv = false; %Force reconverting if true
end

stT = tic;

fid = fopen(infp);
if fid == -1
    return
end
%Mini data file is:
%{
#Begin Write:
COL1    COL2    COL3 ...
data1   data2   data3...
data1   data2   data3...
#Skipped        %Some datapoints are skipped: interpolate missing value?
data1   data2   data3...
data1   data2   data3...
#End Write
%}

%Construct output filename
[p, f, e] = fileparts(infp);
nn = str2double(f(1:end-1));
%Assume upper folder starts with MMDDYY
[~, dirnam] = fileparts(p);
%Filename is MMDDYYN##.mat
nameout = sprintf('%sN%02d.mat', dirnam(1:6), nn);
if exist(fullfile(p,nameout), 'file') && ~tfreconv
    fprintf('File %s already found, skipping\n', nameout)
    fclose(fid);
    return
end


%Grab column names, while skipping rows that start with # (the first and last row, and skipped values)
%Should be '#Begin Write:', then columns
st = fgetl(fid);
if ~strcmp(st, '#Begin Write:')
    %Check if this is a 0byte file
    zz = dir(infp);
    if zz.bytes == 0
        warning('Empty file %s, exiting', nameout)
        fclose(fid);
        return
    else
        error('Unknown filetype (or empty) in file %s, exiting', nameout)
    end
end
hdr = fgetl(fid);

%Extract column names into string array
colnams = textscan(hdr, '%s');
colnams = colnams{1}';
ncols = length(colnams);

%Create formatting string ('%f ' repeated numColumns times)
fmt = repmat('%f ',1,ncols);

%Read data. Some are 'skipped' mark as NaN for now
% 
datraw = cell(1e5,ncols); %Just prealloc some slots
drind = 1;
fileno = 0;
while true
    %Read with textscan
    tmp = textscan(fid, fmt);
    %Add to datraw
    datraw(drind,:) = tmp;
    drind = drind + 1;
    
    %Get line that textscan stopped at
    tmpl = fgetl(fid);
    switch tmpl
        case '#Skipped'
            %For a skipped value, replace with NaNs
            datraw(drind,:) = repmat({nan}, 1, ncols);
            drind = drind + 1;
        case '#End Write' %End of file, break
            break
        otherwise
            if feof(fid)
                %If we're at the end of this file but haven't seen '#End Write', then there's another file
                %Check for next file
                fid2 = fopen( fullfile(p, [f(1:end-1) f(end)+fileno+1 e]) );
                if fid2>0 %Make sure this file at least exists
                    fid = fid2;
                    fileno = fileno + 1;
                    %Read first line, the column headers
                    fgetl(fid);
                else
                    warning('Missing file: %s\\%s.txt?' ,dirnam(1:6), [f(1:end-1) f(end)+fileno+1])
                    break
                end
            else
                warning('Something maybe went wrong? Dont know how to handle this file')
                break
            end
    end
    
end
%Last row might be unfinished if canceled mid-write? fix
tmp = datraw(drind-1,:);
lls = cellfun(@length, tmp);
tmp2 = cellfun(@(x) x(1:min(lls)), tmp, 'Un', 0);
datraw(drind-1,:) = tmp2;

%Concatenate datraw
datraw = cell2mat(datraw);

%Missing values are NaNs, interpolate
len = length(datraw(:,1));
tfnan = isnan(datraw(:,1))';
missval = find(tfnan);
maxdif = 10; %Max pts to search +/-. Greatly increases speed (~20x cf. searching the entire length)
for i = 1:length(missval)
    %Get this index
    curind = missval(i);
    %Get the neighborhood within maxdif of this point
    lb = max( curind - maxdif , 1);
    ub = min( curind + maxdif, len);
    %Find next non-NaN index
    nexind = find( ~tfnan(curind+1:ub) , 1, 'first' ) + curind ;
    %Find prev non-NaN index
    preind = find( ~tfnan(lb:curind-1) , 1, 'last' ) + lb -1;
    
    %Check: Both points exist (i.e., it's not #Skipped \n #End Write or a long #Skipped section)
    if isempty(nexind) || isempty(preind)
        %Just leave as NaN
        continue
    end
%     %Check: If too long (over say 10 pts) ignore
%     if nexind - preind > 10
%         %Just leave as NaN. Probably no longer needed with maxdif
%         continue
%     end
    %And fill in the value
    if nexind - preind == 2 %Shortcut to mean for just one missing value, which should be most of the cases
        tmp = mean(datraw([preind nexind], :), 1);
    else %Interpolate for more complex cases (multiple missing values)
        tmp = interp1([preind nexind] , datraw([preind nexind], :), curind );
    end

    datraw(curind, :) = tmp;
end

fclose(fid);

%Trim the data to what we want - force, extension, time
stepdata.time = {datraw(:,  strcmp(colnams, 'time(sec)'))'};
stepdata.force = {-datraw(:, strcmp(colnams, 'Y_force'))'};
stepdata.forceT = {datraw(:, strcmp(colnams, 'Tension'))'}; %Let's use just Y_force, but also have the option for Tension
stepdata.contour = {(datraw(:, strcmp(colnams, 'A_dist-Y')) + datraw(:, strcmp(colnams, 'B_dist-Y')) )' /2};

%Zero time
stepdata.time{1} = stepdata.time{1} - stepdata.time{1}(1);

%Save
save(fullfile(p, nameout), 'stepdata');

fprintf('Saved %s in %0.2fs\n', nameout, toc(stT))

if nargout
    outData = stepdata;
end





