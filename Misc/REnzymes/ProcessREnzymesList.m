function out = ProcessREnzymesList(inList)

%Rows are now {Name Name0 Source Author Site Methylation Vendor Refereence}
%Removes non-commercial ones, ignores methylation sensitivity
%Ends up with: {Name Site(formatted) Site Site(comp) Site(regexp) Site(comp, regexp) CutParams Vendor}


len = size(inList, 1);

nt.A = 'A';
nt.T = 'T';
nt.G = 'G';
nt.C = 'C';
nt.R = '[AG]';
nt.Y = '[CT]';
nt.M = '[AC]';
nt.K = '[GT]';
nt.S = '[GC]';
nt.W = '[AT]';
nt.B = '[CGT]';
nt.V = '[ACG]';
nt.D = '[AGT]';
nt.H = '[ACT]';
nt.N = '[ATGC]';

ntc = {'AT' 'GC' 'RY' 'MK' 'BV' 'DH'};% N, S, and W are self-complements, can ignore

    function outNt = getComplement(inNt)
        outNt = fliplr(inNt);
        %Swap pairs found in ntc
        for ii = 1:length(ntc)
            in1 = outNt == ntc{ii}(1);
            in2 = outNt == ntc{ii}(2);
            outNt(in1) = ntc{ii}(2);
            outNt(in2) = ntc{ii}(1);
        end
    end

    function outNt = ntToRegExp(inNt)
        outNt = '';
        %Process site for regexp (replace letters with relevant expressions)
        for ii = 1:length(inNt)
            outNt = [outNt nt.(inNt(ii))]; %#ok<AGROW>
        end
    end

    function outCutParams = processCut(inSite)
        %Sites come in three flavors:
         %^: Cut is made somewhere in the sequence
         %(a/b): Cut is made outside the sequence. Can appear at both ends.
        %outCutParams = [cutA cutB] where first nt = 1, cut is after ith nt
        %Should put this info in relist, since it doesn't change.
        
        %Check for ^
        carrot = regexp(inSite, '\^');
        if carrot
            outCutParams = [carrot-1, length(inSite)-carrot];
            return
        end
        ind1 = regexp(inSite, '(');
        ind2 = regexp(inSite, '/');
        ind3 = regexp(inSite, ')');
        outCutParams = zeros(length(ind1), 2);
        lettrs = regexp(inSite, '[A-Z]');
        rawsite = inSite(lettrs);
        for ii = 1:length(ind1)
            num1 = str2double(inSite(ind1(ii)+1:ind2(ii)-1));
            num2 = str2double(inSite(ind2(ii)+1:ind3(ii)-1));
            nums = [num1 num2];
            if ind1(ii) == 1 %Position is relative to start
                dnum = 0;
                nums = -nums;
            else %Position is relative to end
                dnum = length(rawsite);
            end
            outCutParams(ii, :) = nums + dnum;
        end
    end



out = cell(0,8);
for i = 1:len
    %Skip if not commercial
    if isempty(inList{i,7})
        continue
    end
    name = inList{i,1};
    vnd = inList{i, 7};
    sitefmt = inList{i,5};
    letters = regexp(sitefmt, '[A-Z]');
    site = sitefmt(letters);
    sitec = getComplement(site);
    if isequal(site, sitec);
        sitec = '';
    end
    
    regsite = ntToRegExp(site);
    regsitec = ntToRegExp(sitec);
    
    cutpars = processCut(sitefmt);
    %blunt ends, skip
    if isequal(cutpars(1), cutpars(2))
        continue
    end
    
    out(end+1, :) = {name sitefmt site sitec regsite regsitec cutpars vnd }; %#ok<AGROW>
end
out = mergeIsochiz(out);
end
    