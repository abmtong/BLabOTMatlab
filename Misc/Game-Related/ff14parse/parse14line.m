function out = parse14line(inll)

%Parses a ff14 damage line

%Output, if Damage: {'Damage' TIME USER TARGET DAMAGE tfCRIT tfDAMAGE}
%Output, if Skill : {'Skill' TIME USER NAME}
%Output, else: -1

%Log format:
%A log line from ACT can be various things, some useful, some not

%All things are of the type:
%NN|YYYY-MM-DDTHH:MM:SS.milliss-TZONE|CODE||Text|LONGCODE
%Some are different, some codes are longer, these seem to be world events ?

%Text is ususally a sentence like "You use Contre Sixte." or "Direct hit! The [target] takes [number] damage.

%From each line, we want to get the USER, the TIME, the SKILL, and the DAMAGE (if any) of it

%Seems like NN tells us whether this is a normal or other log:
%{
    00: What we care about
    others: ???
%}

%Seems like CODE corresponds to what type of text it is?
%{
    0aa9 : Your damage: '[Critical/Direct hit!] The [target] takes [number] damage.
    22a9 : Else's damage: '[Critical/Direct hit!] [Name] hits [target] for [number] damage.
    082b : Your casts: 'You [begin] [use/casting] [skill]'
    08ae : Your buffs
    08b0 : Your buffs ending
%}

%So let's get parsing

%The log lines are separated by pipes, so let's do that too. We'll add a virtual pipe to the beginning and end
pip = [0 find(inll == '|') length(inll)+1];
%And get the segments
snps = arrayfun(@(x,y) inll(x:y), pip(1:end-1), pip(2:end), 'Un', 0);

%First segment: nn. Only want if it is 00
nn = str2double(snps{1});
if nn ~= 0 %Ok maybe should do a string equality instead of a str2double ==, but gonna assume it's an %02d
    out = -1;
    return
end

%Ok, so we probably want this line. Get its timestamp
time = datetime(snps{2}, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSSSXXX');

%And then parse its Text







