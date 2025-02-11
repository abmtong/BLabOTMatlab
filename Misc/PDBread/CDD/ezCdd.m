function out = ezCdd(incell, chainID)
%Run importCDD > cddColorBits > setBs in order
% So: Copy-paste the sequence box on CDD, import as cell, this is incell
% Download the PDB, run this with just incell input, select the PDB when prompted

seqaln = importCDD(incell);

% if nargin < 2 || isempty(pdbstartres)
%     pdbstartres = 1; %Use to shift if the PDB numbering starts from nonzero. Maybe write this into setBsCdd
% end

%Get chainID from incell if not supplied
if nargin < 2
    %Strip chainID from PDBid if it's there. Try to scan as 'PDB_CHAIN' like '1BXK_A';
    ts = textscan(seqaln(1).name, '%s', 'Delimiter', '_');
    ts = ts{1};
    if length(ts) > 1;
        pdbID = ts{1};
        chainID = ts{2};
    else
        pdbID = '--';
        chainID = 'A';
    end
end

ccdbits = cddColorBits(seqaln);

[f, p] = uigetfile('*.pdb');
infp = fullfile(p,f);

%Set Bs and get PDB
pdbstartres = setBsCdd(infp, ccdbits, chainID);
% Note that pdbstartres ~= startres. pdbstartres is the number of the first aa of the pdb chain, startres = the first residue in alignment

%Shift by pdbstartres
ccdbits(:,1) = ccdbits(:,1) + pdbstartres - 1;

%Get secondary structure annotation. Limit to chainID

secstr = getPdbSs(infp);
secstr = secstr( strcmp( {secstr.chain}, chainID ) );

%Set popup for metadata
inqs = {'CDD Family' 'CD Root' 'CD ID' 'Name' 'PDBid' 'Chain' 'AA Start' };
def = { 'NADB Rossmann' ''        ''      ''     pdbID    chainID sprintf('%d', pdbstartres) };  
uii = inputdlg( inqs, 'ezCDD_metadata', 1, def );

%Assemble output
out.name = strtrim(uii{4});
out.pdb = strtrim(uii{5});
out.pdbch = strtrim(uii{6});
out.pdbst = str2double(uii{7});
out.bits = ccdbits;

out.cddfam = strtrim(uii{1});
out.cddroot = strtrim(uii{2});
out.cddid = strtrim(uii{3});
out.raw = incell;
out.secstr = secstr;

%Try getting ross
try
    tmp = findRoss(secstr);
    if ~isempty(tmp)
        out.ssez = tmp.ss;
    else
        out.ssez = [];
    end
catch
    out.ssez = [];
end
