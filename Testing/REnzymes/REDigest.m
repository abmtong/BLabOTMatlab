function outCuts = REDigest(inSeq, renz)
%Takes in a genome, spits out the site digest
%outCuts {Enzyme site sitepos matchstrand overhangstrand 5'overhang}
%renz = {1name 2fmtsite 3site 4sitec 5regexpsite 6regexpsitec 7cutinds 8vendor}

maxcuts = 30;


len = size(renz,1);
outCuts = cell(0,6);

ntc = {'AT' 'GC' 'RY' 'MK' 'BV' 'DH'};% N, S, and W are self-complements, ignore
    function inNt = getComplement2(inNt)
        %Different from other getComplement which also flips - this just translates
        %inNt = fliplr(inNt);
        %Swap pairs found in ntc
        for ii = 1:length(ntc)
            in1 = inNt == ntc{ii}(1);
            in2 = inNt == ntc{ii}(2);
            inNt(in1) = ntc{ii}(2);
            inNt(in2) = ntc{ii}(1);
        end
    end

%Check every enzyme
for i = 1:len
    %Extract matching sequence
    match5 = regexp(inSeq, renz{i,5});
    match3 = regexp(inSeq, renz{i,6});
    
    match = [ [match5; zeros(size(match5))] [match3; ones(size(match3))] ];
    
    if length(match5) + length(match3) > maxcuts
        continue
    end
    
    %Normal case, seq matches 5' strand: if issorted cutinds, overhang is fine, else complement the overhang
    for j = 1:size(match,2)
        cutinds = renz{i,7};
        %Some enzymes cut twice, take account for that
        for k = 1:size(cutinds,1)
            cutind = cutinds(k,:);
            %Process which strand the match was on
            if match(2,j) %3' match, convert to 5' reference
                cutind = fliplr(-cutind -1);
                matchstrand = '3''';
            else
                matchstrand = '5''';
            end
            tf = issorted(cutind);
            num1 = cutind(1);
            num2 = cutind(2);
            %Add 1 to lower number to switch from cut location to substring index
            if num1 < num2
                num1 = num1 + 1;
            elseif num2 < num1
                num2 = num2 + 1;
            end
            overind = match(1,j)-1 + sort([num1 num2]);
            try %To catch array out of bounds , i.e. if cut site is off of the sequence
                overhang = inSeq(overind(1):overind(2));
                %If sorted xor 3', 
                if xor (tf, match(2,j) )
                    overstrand = '5''';
                else
                    overstrand = '3''';
                    overhang = getComplement2(overhang);
                end
            catch
                continue
            end
            if num1 == num2 %blunt ends
                overstrand = 'blunt';
                overhang = 'N/A';
            end
            %                   Name       Site     Location    MatchStrand OverhangStrand OverhangNT
            outCuts(end+1,:) = {renz{i,1} renz{i,2} match(1,j)  matchstrand overstrand overhang }; %#ok<AGROW>
        end
    end
end
end