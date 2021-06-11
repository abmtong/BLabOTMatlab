function out = trSpAs(elv)
%Guesses the affixes for Spire Assault

%Known:
%{
Level: Names [Numbers] , [Guesses *errors] Dust
29: Sh Sh Li Df Fa    [7 7 8 4 2]     , [7 8 4 2 7] 45k

31: En He Po Sh BR PR [12 1 5 7 11 9] , [12 1 5 7 11 10*] 71k
32: Fa Bl Sh Sh BR Po [2 6 7 7 11 5]  , [2 6 7 7 11 6*];
33: St BR Df Bl Sh Fa [3 11 4 6 7 2]  , [3 11 5* 7* 8* 2];
34:                               []  , [8 8 12 1 11 7]
35: Li De Sh Sh BR Fa [8 4 7 7 11 2]  , [8 4 7 7 11 3*]
36: BR PR Sh Sh He St [11 9 7 1 7 3]  , [11 10* 9* 1 9* 4*]; very wrong ... ?
37: St St He Po SR De [3 1 5 3 10 4]  , [3 1 5 3 10 4];
38: Bl Po SR Li En Df [6 5 10 8 12 4] , [6 5 10 9* 11* 4];
39: Po Li He Sh Df Df [5 8 1 7 4 4]   , [5 8 1 7 4 4] 418k %No resists
40: Sh Sh En BR Fa PR Po [7 7 12 11 2 9 5] , [7 7 12 11 2 10* 7*] 520k
41: PR En He He Bl Po Po [9 12 1 6 1 5 5]  , [9 12 1 6 1 5 6*]; %Too healthy...
42:                                     [] , [6 12 1 9 6 9 2]; 799k Bld+Shk able
43:                                     [] , [2 5 1 4 2 3 2] % FAAAST, promising
44:                                     [] , [10 12 10 8 2 10 2]; Fast, not BldRes ... maybe??
45:      [] , [7 7 2 5 8 9 4]
%Hmm this seems to be off by a bit.  Guessing differing implementations of @sin in Matlab vs Js

Level to farm: 29 (no resists, so Bld-Shk works)
 Would like to find a better farm lv before grinding 9th arm etc...
  Looks like there isn't one (on Z41).
 Must avoid BR SR, prefer not He Df, and must have Fa
Apparently 43 45 47 next farm zone (at 43, need a smidge to farm it)

1	Healthy   % HP *= (1+min(1,elv/30))
2	Fast      % AS *= max(.5, 0.98^elv)
3	Strong    % Atk *= (1+min(1,elv/30))
4	Defensive % Def += ceil(elv*.75) * 1.05^(elv)
5	Poison    % 3% Chc/elv, 0.2 Dmg/elv
6	Bleed     % 3% Chc/elv, 5% Dmg/elv
7	Shock     % 3% Chc/elv, 6.6% Dmg/elv
8	Lifesteal % LS += min(1, elv/50)
9	PoiRes    % PR += 10*elv
10	ShkRes    % SR ''
11	BldRes    % BR ''
12	Enrage    % Enrage 10s sooner, 10% worse (60s, +50% -> 50s, +60%)


%}


seed0 = 4568654;

%From setProfile, line 2268 objects.js (5.5.1)

s = seed0 + elv * 100;

%Set available affixes
fx = {'He' 'Fa' 'St' 'Df'};
if elv > 5
    fx = [fx {'Po' 'Bl' 'Sh' 'Ls'}]; %Poison/Bld/Shock/Lifesteal
end
if elv > 10
    fx = [fx {'PR' 'SR' 'BR'}]; %Resists
end
if elv > 20
    fx = [fx {'En'}]; %Enrage
end

%Set number of affixes to roll
if elv < 25
    nfx = ceil( (elv + 1 ) / 5 );
else
    nfx = 4 + ceil( (elv-19) /10 );
end
% nfx = 20; %debug

%Roll for the affixes
fxi = zeros(1, nfx);
for i = 1:nfx
    %Get a random integer and add it to the effects list
    n = trandi(s + i - 1, length(fx));
    fxi(i) = n; %Should be checking for max level, but aren't here (rolls over)
end

% out = fx(fxi);
out = fxi; %Not sure if we want indices or names. Indexes easier to deal with for inconsistencies

%Add dust amt (base)
dus = (1 + (elv-1)*5 )*1.19^(elv-1)* 1.1^max(elv-49, 0) * (1+elv*0.05);
%Per level, 24% more ish (~ + 20% + 1/elv), increasing to 30% per at elv50
out = [out dus];
end

%Define Trimps' RNG
function out = trand(s)
x = sin(s) * 1e4; %Hmm this is a s++ : doesn't affect execution here, but does this increment s for later?
x = x - floor(x);
out = round( x ,7) ; %Round to 7 digits. May round to 1 , be aware
end


function out = trandi(s, imax)
out = floor( trand(s) * imax ) +1; %Change from 0-index to 1-index
if out > imax %trand might output 1, in that case loop around to 1
    out = 1;
end
end