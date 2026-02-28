function [outadd, outsub] = getMoves(cc, cmap)
%Gets available moves given a current connected component (1xn) + overall connection map (nxn)
% States are defined by residues involved in each CC (and all contacts within these residues are made)

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

%Addition move: Get adjacent vertexes, test if ok, then list ok if good
%Subtraction move: Try subtracting every vertex, only keep ones that are 'ok'

%Use @conncomp to make this easier? how good is conncomp?
% @conncomp doesn't seem to be able to handle 'hinges'
% Hinges are a single residue that connects two separate CCs... so maybe do 'double deletions' ?
% Like it must survive the test deletion + all others

%Get addition moves:
%Get set of allowable contacts. These are residues that make a contact with the current state but not in the current state
%Get list of residues that contact the CC in the native state
adjres = sum(cmap( logical(cc) ,:) , 1);
adjres = find(adjres);
%Add the list of the current CC and unique to get single residues
ccno = find(cc(:)');
adjres = unique([adjres ccno]);
%'Subtract' the residues from the current CC to get the list of potential additions
adjres = setxor(adjres, ccno);
%And test each for validity
len = length(adjres);
ki = false(1,len);
for i = 1:len
    newcc = cc;
    newcc( adjres(i) ) = 1;
    ki(i) = isOkCC(newcc, cmap);
end
outadd = adjres(ki);

%Get subtraction moves:
%For each residue in CC, attempt removing one residue, and check if ok
len = length(ccno);
ki = false(1,len);
for i = 1:len
    newcc = cc;
    newcc( ccno(i) ) = false;
    ki(i) = isOkCC(newcc, cmap);
end
outsub = ccno(ki);

%I guess this should work? Assuming I can write a good isOkCC. Seems OK???





