function out = loadmdout(infp)
%Parses an Amber mdout file from REMD simulation (could probably work for others, too)

%Basically, there will be a series of info that looks like this:
%{
 NSTEP =        0   TIME(PS) =       0.000  TEMP(K) =     0.00  PRESS =     0.0
 Etot   =      -129.1691  EKtot   =         0.0000  EPtot      =      -129.1691
 BOND   =        44.6370  ANGLE   =        80.5647  DIHED      =        96.8251
 1-4 NB =        36.2986  1-4 EEL =       326.7339  VDWAALS    =       -28.2108
 EELEC  =      -547.1481  EGB     =      -139.0148  RESTRAINT  =         0.1454
 EAMBER (non-restraint)  =      -129.3145
 TEMP0  =       369.1400  REPNUM  =              6  EXCHANGE#  =              0
 ------------------------------------------------------------------------------

 NMR restraints: Bond =    0.000   Angle =     0.000   Torsion =     0.145
===============================================================================
| Exch         1 RREMD= 0
| Replica        Temp= 369.14 Indx=  6 Rep#=  6 EPot=    -129.17
| RepId     6 CrdIdx=     5
| Partner        Temp= 392.97 Indx=  7 Rep#=  7 EPot=    -127.32
| Metrop    0.858030E+00 delta=     0.153116E+00 o_scaling=       0.97
| Rand=     0.239409E+00 MyScaling=       1.03 Success= T
%}
% We want to parse this and grab out whatever we can. Basically, grab the top data
%  So look for a line that starts ' NSTEP =' and end at ' --------'

if nargin < 1
    [f, p] = uigetfile('*.mdout.*');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

fid = fopen(infp);
lnsig = ' NSTEP = '; %String to mark the start of a new data
scanstr = '%s %f'; %String for textscan
fkeep = {'NSTEP' 'EPtot' 'TEMP(K)' 'TEMP0' 'REPNUM' 'EXCHANGE#' 'RESTRAINT'}; %Data to keep, scan format
flen = cellfun(@length, fkeep);
fsave = {'nstep' 'EPtot' 'tempk' 'temp0' 'repnum' 'exchnum' 'Erestraint'}; %Fieldname to save it as
% What energy to use? EPtot? EAMBER?

%Let's just scan line by line...
out = cell(1, 1e5); %Just prealloc 1e5 timesteps for now...
ind = 1;
while ~feof(fid)
    ln = fgetl(fid);
    
    %Let's just sort lines until we reach the ' NSTEP =' line, and then sort from there?
    if strncmp(lnsig, ln, length(lnsig))
        data = cell(1,10); %One per line. Go until we reach a ' ---------' line, lets say max 10 lines
        %Read these NSTEP = 0's as %s = %f
        data{1} = textscan(ln, scanstr, 'Delimiter', '=');
        
        %Read up to 6 more lines. Sometimes 5, sometimes 6? doesn't break if it's always 6?
        % Seems like the EAMBER (non-restraint) doesn't show up if restraint == 0 (makes sense)
        % EAMBER seems to just be EPtot minus RESTRAINT
        for i = 1:10
            tmp = fgetl(fid);
            %Check for end:
            if strcmp(unique(tmp), ' -')
                data = data(1:i);
                break
            end
            
            data{i+1} = textscan(tmp, scanstr, 'Delimiter', '=');
        end
        
        %Assemble data together
        fnams = cellfun(@(x) x{1}', data, 'Un', 0);
        fnams = [fnams{:}];
        vals = cellfun(@(x) x{2}', data, 'Un', 0);
        vals = [vals{:}];
%         vals = num2cell(vals);
        
        %Extract the rows that matter
        tmp = [];
        for i = 1:length(fkeep)
            tmp.(fsave{i}) = vals( strncmp(fnams, fkeep{i}, flen(i) ) );
        end
        %Save as struct
        out{ind} = tmp;
        ind = ind + 1;
    end
end

out = [out{:}];

%Maybe better to have this as a 1x1, not a 1xn struct... but eh




 