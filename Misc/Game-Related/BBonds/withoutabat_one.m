function [panobat, OBP] = withoutabat_one(pf, pid, zonepct, zoneswpct, verbose)
%Inputs: filepath of .EVX file, RetroSheet PlayerID

if nargin<1 || isempty(pf)
    pf = '.\2004eve\2004SFN.EVN';
end

%RetroSheet's player name
if nargin < 2 || isempty(pid)
    pid = 'bondb001';
end

%Define chances of fair pitch in general
%This agrees with Bois' number of .413
%From FanGraphs, this is just Zone% *Do I need to take into account IBall%?
if nargin < 3 || isempty(zonepct)
    zonepct = 0.4132; %Bonds in 2004
end
%From FanGraphs, this is Zone% * Z-Swing% / Swing%
%This slightly differs from Bois' number of 0.809
%We want (Swing & InZone) / Swing, which is = (Swing & InZone / InZone) * (InZone / AllPitches) / (Swing / AllPitches) = Z-Swing% * Zone% / Swing%
if nargin < 4 || isempty(zoneswpct)
    zoneswpct = 0.7867; %Bonds in 2004
end

%Could take into account HBP%, if HBP are truly errors

if nargin < 5
    verbose = 1;
end

%Format of a PA line, to be used with @regexp later
%Format is: play,inning,player,home/away,count,pitches,event
%We really only care about if the player is the one we want, and if so the pitches they saw
%See https://www.retrosheet.org/eventfile.htm for more info
paln = sprintf('play,\\d*,\\d*,%s,\\d*,(\\w*),\\w*', pid);

%Load lines of the .EV* file
fid = fopen(pf);
ts = textscan(fid, '%s');
ts = ts{1};
fclose(fid);

%Extract plate appearances by finding lines that match paln
pas = cellfun( @(x) regexp(x, paln, 'tokens'), ts, 'Uni', 0) ;
%Remove empty lines (lines that don't contain player's PA)
pas = pas(~cellfun(@isempty,pas));

%If the player never played in this stadium, pas is now empty, Return nothing
if isempty(pas)
    panobat = [];
    OBP = nan;
    return
end

%Matlab puts this in a cell array 1x1 cells of 1x1 cells of strings, let's make this a cell array of strings
pas = [pas{:}];
pas = [pas{:}];
len = length(pas);

%Capture no-bat outcomes here:
panobat = -ones(1,len);
%We'll say -1 is a no-play, 0 is BB, 1 is SO
%Calculating the expected chance of an out for a generic PA is hard, so we'll just Monte Carlo it by running this whole code multiple times

%process PAs
for i = 1:len
    %load pa
    pchs = pas{i};
    %if PA is empty, this was a no-play because of substitution, skip
    if isempty(pchs)
        continue
    end
    %simulate pitch by pitch
    b = 0; %num balls
    s = 0; %num strikes
    n = 0; %number of pitches
    while true
        %get next pitch
        n = n + 1;
        if n <= length(pchs);
            pitch = pchs(n);
        else
            pitch = 'Z'; %New pitch, simulate
        end
        %find outcome of pitch
        switch pitch
            case {'B' 'I' 'V' 'Y' 'P' 'Q' 'R'} %Ball/I-ball/mouth penalty/pitchout(there are 4 of these) is a guaranteed ball
                b = b + 1;
            case 'C' %Called strike is a guaranteed strike
                s = s + 1;
            case {'F' 'S' 'T' 'X'} %Foul, Swinging strike, foul Tip, and Hit use the swinging strike probability
                if rand() < zoneswpct
                    s = s + 1;
                else
                    b = b + 1;
                end
            case 'H' %HBP = automatic walk
                b = 4;
            case {'Z' 'L' 'M'} %New pitch, and im going to say bunts = any pitch, because a player can bunt an arbitrary ball (?)
                if rand() < zonepct
                    s = s + 1;
                else
                    b = b + 1;
                end
            case 'K' %Unknown strike, ignore
                fprintf('Unknown strike on PA %d, skipping\n', i);
            case 'U' %Unknown pitch, ignore
                fprintf('Unknown pitch on PA %d, skipping\n', i);
            otherwise %Any other symbol will be ignored, e.g. steal-related pickoff throws
        end
        
        %check if we're done
        if b == 4
            panobat(i) = 0;
            break
        elseif s == 3
            panobat(i) = 1;
            break
        end
    end
end

%Print OBP
OBP = sum(panobat == 0) / sum(panobat ~= -1);
if verbose
    fprintf('Player %s had an OBP of %0.3f\n', pid, OBP);
end


%First: Estimate percent strike / ball for swinging/looking












