function out = inhouse_balance()
%Let's make this a gui why the fk not

f= false;
t = true;
players = {
    'Cheez'  f t f t 3700 3000 3700 [];
    'Scooty' f t t t 3900 3300 3300 [];
    'Glen'   f t t t 3400 3000 3300 [];
    'Saki'   f f t t -1   3500 3300 [];
    'Shiny'  f t t t 3500 3400 3400 []
    };

%Create figure
fg = figure('Name', 'inHouse Balance', 'Position', [ 480 270 960 540 ]);
%Table to hold players. Make it ~20 rows, with columns {Name tfPlaying(1x1 logical) tfRole(1x3 logical) srRole(1x3 double) Teammates}
coltitles = {'Name' 'Playing?' 'Tank' 'DPS' 'Support' 'SRtank' 'SRdps' 'SRsupp' 'Teammates'};
colform = {'char' 'logical' 'logical' 'logical' 'logical' 'numeric' 'numeric' 'numeric' 'numeric' 'numeric'};
tbl = uitable  ('Units', 'normalized', 'Position', [.1 .4 .8 .5], 'Data', players, 'ColumnName', coltitles, 'ColumnFormat', colform, 'ColumnEditable', true);
%Buttons for actions

roles = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [.1 .3 .1 .1], 'String', 'TTDDSS');
nplayers = uicontrol('Style', 'text', 'Units', 'Normalized', 'Position', [.1 .3 .1 .1], 'String', sprintf('%d',sum([tbl.Data{:,2}])));

%Some counter for N players, to make sure they're equalish

%Output team comps
end

function outTeams = balanceTeams(~,~)
%Get the table 
ps = tbl.Data;
ps = ps([ps{:,2}] ,:);
%Check N Players
np = size(ps, 1);
rs = roles.String;
assert(np == 2*length(rs), 'Wrong number of players')
%Assume there are enough TDS players to fill roles...

%Randomly generate teams and pick the fairest ones?


end

function [teamA, teamB] = randteam(ptbl, roles)
%Simplify roles , kinda useless now but eh
nt = 2*sum(roles=='T');
nd = 2*sum(roles=='D');
ns = 2*sum(roles=='S');
pt = [ptbl{:,2}];
pd = [ptbl{:,3}];
ps = [ptbl{:,4}];
[pt, pd, ps] = simplifyRoles(pt, pd, ps, nt, nd, ns);

%Choose roles for role flexers
rolmat = [pt pd ps];

%Try every remaining combo and find team that results
%Generate with bsxfun, roles are a 'barcode' number
%'barcode' is role comp pairs to number (TDS = 1/2/3 base 3, use pairs)
%It is in 'reverse endian' where the first two players are ones place, next two tens place, etc.
%Player 1 = +012, player 2 = +0/3/6, for T/D/S ; then +1 to make sure it's nonzero (no leading zero)
teams = getTeams_recurse(0, rolmat, 1);

%Remove teams that don't fit the roles
tok = checkTeam(teams, [nt nd ns]);
teams = teams(tok);

%For each group of roles, split players and try to have evenish SR



%Rank based on closeness of net SR and per-role SR

%Collect the five best, output to dropdown menu


end

function out = getTeams_recurse(teams, roleids, iter)
%Roleids is a nplayer x nroles array

%End case
if iter > size(roleids,1)
    out = teams;
    return
end

%Get just the ones we want
roles = roleids(iter,:);
r = 0:2;
r = r(logical(roles));
%Add each to teams, and split where necessary
mult = (1 + mod(iter-1,2)*2) * 10^(floor((iter-1)/2)); %Role multiplier goes 1, 3, 10, 30, ... so, for each digit, the /3 and mod 3 gives two roles
x = arrayfun(@(x) x + r*mult, teams, 'Un', 0);
teams = [x{:}];

%Recurse, incrementing iter
out = getTeams_recurse(teams, roleids, iter+1);
end

function tf = checkTeam(teamnum, comp)
%TDS = 1 2 3
teamnum = num2role(teamnum);
tm = [sum(teamnum == 1)  sum(teamnum == 2) sum(teamnum == 3)];
tf = all( tm == comp);
end

function outroles = num2role(teamnum)
%It's in base-9 but written in base-10
numstr = sprintf('%d', teamnum);
ndig = length(numstr);
outroles = zeros(2,ndig);

%For each digit...
for ii = 1:ndig
    dg = numstr(ii);
    dg1 = mod(dg, 3);
    dg2 = floor(dg/3);
    outroles(:,ndig) = [dg2;dg1]; %Will reverse later
end
outroles = outroles(:)';
outroles = outroles(end:-1:1)+1;
end

%Simplify the table by locking roles when we don't have enough of them left
function [pt, pd, ps] = simplifyRoles(pt, pd, ps, nt, nd, ns)
np = length(pt);
oldvec = [pt pd ps];
%Check tanks
if pt == nt
    for i = 1:np
        if pt(i)
            pd(i) = false;
            ps(i) = false;
        end
    end
elseif pt < nt
    error('Not enough tanks!')
end

%Check dps
if pd == nd
    for i = 1:np
        if pd(i)
            pt(i) = false;
            ps(i) = false;
        end
    end
elseif pt < nd
    error('Not enough dps!')
end

%Check supports
if ps == ns
    for i = 1:np
        if ps(i)
            pd(i) = false;
            pt(i) = false;
        end
    end
elseif pt < ns
    error('Not enough supports!')
end

%There might have been changes that locked another role. Recurse until no changes
if all(all(oldvec == [pt pd ps]))
    return
else
    [pt, pd, ps] = simplifyRoles(pt, pd, ps, nt, nd, ns);
end
end

%Output table be like
%Name(SR) Role Name(SR) ; do Tank(SR_avg)


