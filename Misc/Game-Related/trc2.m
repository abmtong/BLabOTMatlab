function out = trc2(z, scls)
%Calculates C2 pct. for
%Mimics getIndividualSquaredReward bc idk how Erad math works
% LOL NVM i was looking at Cinf% not C2%, works fine

if nargin < 2
    %[Thresh Reward Growth Freq];
%     scls = [100 3 3 10]; %Default, mesmer
%     scls = [50 1 2 10]; %Trapper
%     scls = [40 3 3 10]; %Trimp
%     scls = [30 1 1 3]; %Coordinate
    scls = [10 1 1 1]; %Oblit
%     scls = [2 10 2 1]; %Erad
    
end

%Unpack
thr = scls(1);
rew = scls(2);
gro = scls(3);
frq = scls(4);

obsStart = 701;

loops = ceil(z/thr);
out = 0;
addedB = 0;

for i = 0:loops-1
    if i == loops-1 %How many zones to award at this 'slice'
        count = z - addedB;
    else
        count = thr;
    end
    
    toAdd = count - mod(count, frq); %Scale down to previous award Z
    
    extraB = 1;
    
    if addedB + toAdd > obsStart;
        if addedB >= obsStart %If all zones in obsidian, 5x
            extraB = 5;
        else %Otherwise prorate the obsidian zones. This causes a bug (?) for Z701 not being counted as 5x
            nonB = obsStart - addedB;
            overCap = addedB + toAdd - obsStart;
            extraB = 1 + (1 / (1 + nonB/overCap))*4;
        end
    end
    
    addedB = addedB + toAdd;
    count = floor(count/frq);
    out = out + count * (gro * i + rew) * extraB;
end
out = round(out);