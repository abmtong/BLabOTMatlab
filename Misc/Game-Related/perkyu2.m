function out = perkyu2(Rn)
%Calculates perks for Trimps U2

%Right now, no separate Rn skills, just HP/Atk, so no need for ratios
% if nargin < 2
%     ratio = 2; %Rn to HP/Atk ratio
% end

if nargin < 1
    Rn = 2e24; %1Sp
end

%Suffixes:
%     k  M  B  T Qa Qi Sx Sp Oc No Dc Un
%10^ 03 06 09 12 15 18 21 24 27 30 33 36

%Hmm since how Eq works, for now weight HP and Atk the same

%TODO: Calculate required Carp for end zone. For now, just weight by 'x' benefit
%Ratio: just Rn to HP/Atk

%Each perk has {@(level) dX , @(level) Cost};
%Most perks have the usual 1.3x scaling (= L/2 + l0 * 1.3 ^L), Eq is 1.5x, Obs 2x, Champ 5x

%HP perks. Since they're just HP, sqrt their value
ps.Res = {@(lv)sqrt(1.1), @(lv) lv/2 + 100 * 1.3^lv};
ps.Tough = {@(lv) sqrt(1+1/(lv+20)), @(lv) lv/2 + 1 * 1.3 ^ lv};
%Atk perks
chd = 1800;
ps.Crit = {@(lv)sqrt( 1 + (10/chd) ), @(lv) 100 * 1.3^lv};
ps.Pow = {@(lv) sqrt( 1+1/(lv+20) ), @(lv) lv/2 + 1 * 1.3 ^ lv};
ps.Frenzy = {@(lv)sqrt( 1+1/(lv+2) ), @(lv) lv/2 + 1 * 1.3 ^ lv};
%HP&Atk perks
ps.Obs = {@(lv) ((lv+1)/lv) ^2, @(lv) lv/2 + 5e18*2^lv};
ps.Champ = {@(lv) 244/192,  @(lv) lv/2 + 1e9 * 5^lv};
ps.Carp = {@(lv) 1.1, @(lv) lv/2 + 25*1.3^lv};
%Rn perks. Actually just Looting...
ps.Loot = {@(lv) 1+1/lv, @(lv) lv/2 + 1 * 1.3 ^ lv};

%Need to think how to weight Carp and Rn
% More Carp = Push farther, and in that case it IS worth 10%/10%
% Can convert HP/ATK x into He using 3%/zone (Each zone is ~2x/2x)
% So HP/ATK does HP/ATK ~and~ Rn, while Looting just does Rn

%And assume we can get enough Eq with the 'scraps' [or reserve ~1% for Eq first]
% ps.Eq = {@(lv) 1 , @(lv) lv/2 + 1 * 1.5 ^ lv};
%And assume Artisanstry is 'maxed enough'
% ps.Art = {@(lv) 1, @(lv) lv/2 + 1 * 1.3 ^ lv};

%For now assume any capped perks are maxed
%{
Greed
Tena
Range
Agility
Prismal
Hunger
%}

%And ignore any 'junk' perks
%{
Bait
Trumps
Phero
Packrat
Motivation
%}

%Now optimize: Evaluate all, pick most value until SpentRn is too much
fns = fieldnames(ps);
npk = length(fns);
lvs = zeros(1,npk);
spentRn = 0;

%May need to switch to eg uint64 for float precision?
%eps(x) ~= x * 2e-16

%Calculate initial costs + values
val = zeros(1,npk); %Value : dX per Rn
cost = zeros(1,npk); %Cost
for i = 1:npk
    cost(i) = ceil(ps.(fns{i}){2}(0));
    val(i) = log(ps.(fns{i}){1}(0)) / cost(i);
end

while true
    %Check which perks we can buy
    canbuy = cost < (Rn - spentRn);
    %If we cant add any more (all too expensive), end
    if all(~canbuy)
        break
    end
    %Buy most efficient perk
    [~, mi] = max(val .* canbuy);
    lvs(mi) = lvs(mi) + 1; %Increase perk level
    spentRn = spentRn + cost(mi); %Add cost
    %Update its new cost + value
    cost(mi) = ceil(ps.(fns{mi}){2}(lvs(mi)));
    val(mi) =   log(ps.(fns{mi}){1}(lvs(mi))) / cost(mi);
%     fprintf('%g\n', spentRn)
end

%Print output
tmp = [fns num2cell(lvs')]';
out = struct(tmp{:});

