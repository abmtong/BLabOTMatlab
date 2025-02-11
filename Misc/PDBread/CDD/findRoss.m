function out = findRoss(inss)
%Finds and annotates Ross secondary structures from a list


% Basically, we... want to find the beta sheet turnover

%Probably: First, take the largest sheet, or search over sheets over 5 strands
% Then, look for patterns of [4 1 2 3] in terms of strand order, N to C
% Then, look for the HELIX between these SSEs

%Let's make the structure of 'out' like this:

%fields:
%{
    sse: SSE number, see below
      a:  4 2   
      b: 5 3 1 7 9
      a:    6   8
        Assume all sheets have that strand 5 (skip if they don't have it)
    res: residue range, copy from inss
%}
% Maybe we can make out just be a 1xn cell of residues.


%First, handle beta
sht = inss( strcmp({inss.type} , 'SHEET') );

%Separate the sheets and get the one with the longest strand
sid = arrayfun(@(x) x.sheetID(end), sht); %sheetID might be like 'AC', for chain A sheet C, so just take C
maxsid = mode(sid);
ski = sid == maxsid;
sht = sht(ski);

%Sort the starts of these strands
[~, si] = sort( arrayfun (@(x) x.res(1), sht ) );

%Get the difference between these indicies
dsi = diff(si);
% We'll search this string for Ross patterns

%Ross-like diff(si) are [-1 -1 3] , [-1 2] for patterns [3 2 1 4] and [2 1 3]
% As well as flip-reverses if numbering goes the other way: [4 1 2 3] and [3 1 2]

rosspatt = {[-1 -1 3], [-1 2] [-3 1 1] [-2 1]};
rosspattdind = [2 1 1 1]; %SS 1 starts at strfind(x, rosspatt{i}) + rosspattdind(i) + 1
has3 = [1 0 1 0]; %Has beta strand 3?
%Add flip-reverses
% rosspatt = [rosspatt cellfun(@(x) -fliplr(x), rosspatt, 'Un', 0)];

%Search for rosspatt in dsi
len = length(rosspatt);
rosses = cell(1, len);
rossh3 = cell(1,len);
for i = 1:len
    rosses{i} = strfind(dsi, rosspatt{i}) + rosspattdind(i);
    rossh3{i} = has3(i) * ones(1, length(rosses{i}));
end
%And concatenate
rosses = [rosses{:}];
rossh3 = [rossh3{:}];

%For each hit in rosses, grab it. from si(rosses(i)) to si(rosses(i)+5. Should just be one, maybe two
fprintf('%d Rosses found\n', length(rosses))

sortb = {sht.res};
sortb = sortb(si);

%Get helix ss's
hel = inss( strcmp({inss.type} , 'HELIX') );
helss = [hel.res];
helss = reshape(helss, 2, [])';
hellen = helss(:,2)-helss(:,1);


len = length(rosses);
out = cell(1,len);
for i = 1:len
    tmp = cell(1,9);
    %Find betas
    
    %Get number of betas
    if rossh3(i)
        nb = 5;
    else
        nb = 4;
    end
    
    tmp(1:2:nb*2) = sortb( si(rosses(i)) + (0:nb-1));
    
    %Find the alphas in between the betas
    for j = 1:nb-1
        %Look for the longest aa between the pair of betas
        rng = [tmp{ 2*(j-1)+1 }(2) , tmp{ 2*(j)+1 }(1) ];
        
        ki = find( all( helss > rng(1) & helss < rng(2),2 ));
        
        
        if ki > 1
            %If there's multiple, pick the longest length
            [~, mi] = max(hellen(ki));
            ki = ki(mi);
        elseif ki == 0
            fprintf('%dth helix not found\n', j)
            tmp{2*j} = [nan nan];
            continue
        end
        tmp{2*j} = helss(ki, :);
    end
    
    %Insert third beta if missing
    if ~rossh3(i)
        tmp = [tmp([1 2 3 4]) {[nan nan] [nan nan]} tmp([5 6 7])];
    end
    
    out{i} = struct('rossID', {i}, 'ss', {tmp});
end

out = [out{:}];








