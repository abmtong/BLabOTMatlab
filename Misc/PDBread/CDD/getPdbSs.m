function out = getPdbSs(infp)
%Get PDB secondary structure annotation
% Basically, lines that start with HELIX or SHEET and then process them
% Yes, pdbread does this by itself but EH

if nargin < 1
    [f, p] = uigetfile('*.pdb');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

a = pdbread(infp);

%Get HELIX records
lnshel = a.Helix;

%Process HELIX records. These are fixed-width, so just do fixed-width processing
len = length(lnshel);
for i = len:-1:1
    %We just want the chain and residue
    tmp = [];
    tmp.type = 'HELIX';
    
    %Sheet ID: so this is concatenatable with Sheet later
    tmp.sheetID = [];
    
    %Chain
    tmp.chain = strtrim( lnshel(i).initChainID );
    
    %Start, End residue
    tmp.res = [ lnshel(i).initSeqNum , lnshel(i).endSeqNum ];
    
    outhel(i) = tmp;
end

%Get SHEET records
lnssht = a.Sheet;

%Process SHEET records.
len = length(lnssht);
for i = len:-1:1
    tmp = [];
    tmp.type = 'SHEET';
    
    tmp.sheetID = strtrim( lnssht(i).sheetID );
    tmp.chain = strtrim( lnssht(i).initChainID );
    tmp.res = [ lnssht(i).initSeqNum , lnssht(i).endSeqNum ];
    %Also add Sheet ID, if there's multiple sheets in one pdb
    
    outsht(i) = tmp;
end

out = [outhel outsht];
