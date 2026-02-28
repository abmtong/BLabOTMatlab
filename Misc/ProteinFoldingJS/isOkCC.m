function tf = isOkCC(cc, cmap)
%Checks if a given CC is allowed
%Paper says allowable states are:
%{
First, we note that every microstate with a specific set of contacts can be decomposed into
disconnected structured regions (Fig. 1 c). Within each structured region,
it is reasonable to assume that the native contacts between interacting residues
are geometrically correlated due to their close spatial proximity. We
therefore require that all possible native contacts be formed within each
structured region (Fig. 1 d). Second, to define a self-consistent configurational
entropy, we do not allow microstates with disordered loops of contact-
forming residues (i.e., residues that make contacts in the native state)
that are shorter than one Kuhn length (see the Supporting Material).

Summarized:
All contacts within one CC are formed
Cannot have a loop of ... two residues that contact? Is equivalent to the 'hinge residue'?

%}

%Check 1: Loops too big
%Get loops, i.e. interior regions of 0's
lp = getLoops(cc);
loopok = 1;
%Basically, we just want loops that are 2 long and
if ~isempty(lp)
    %Bad only if loop length <= 2 and either makes a contact with that region?
    %Check each loop
    for i = 1:size(lp,1)
        %First check size
        if lp(i,3) > 2
            continue
        end
        %Check if any residue in this loop contacts the current CC
        loopcon = cmap( lp(i,1):lp(i,2), cc);
        if any(loopcon(:))
            %If a loop of 2 or fewer residues has a contact with the CC, this is an invalid CC
            loopok = 0;
            break
        end
    end
end

%Check 2: Hinge residue
%I think all hinges, when removed, will split into two separate CCs
% This then should be findable via @conncomp, that there should be
ccno = find(cc);
len = length(ccno);
hingeok = true;
for i = 1:len
    newcc = cc;
    %Remove one residue from cmap
    newcc( ccno(i) ) = false;
    %Check CCs
    newcmap = cmap( newcc, newcc);
    ncc = conncomp( graph( newcmap ) );
    if ncc > 1
        hingeok = false;
        break
    end
end

tf = loopok && hingeok;

