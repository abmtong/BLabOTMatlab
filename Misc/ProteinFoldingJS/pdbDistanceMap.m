function out = pdbDistanceMap(infp)
%PDB data from pdbread
% Needs secondary structure and hbonds, if it isn't in the pdb already, can be added via dssp and hbonds in Chimera

if nargin < 1 || isempty(infp)
    [f, p] = uigetfile('*.pdb');
    infp = fullfile(p,f);
%     dat = pdbread(fullfile(p, f));
%     dat = dat.Model.Atom;
    %Do some sanity check, like taking only one model? eh
end

dat = pdbread(infp);

%Options
mindist = 3; %Interaction sequence minimum, 3 from paper, 'more than 2aa apart'
%Or just calculate for all anyway? (set mindist = 1)
dmax = 4; %Contact distance for heavy atoms

%Separate atom info
atm = dat.Model.Atom;

%Wipe Hs. Remove any AtomName with H? element field seems broken/unreliable
% datnoh = dat( ~strcmp('H', {dat.element} ) & ~cellfun(@isempty, {dat.element} ) );
atmnoh = atm( ~arrayfun(@(x) any(x.AtomName == 'H'), atm) );

nr = max( [atmnoh.resSeq] );
dmap = zeros(nr,nr); %Distance map
nhc = zeros(nr,nr); %N heavy atom contacts
isbb = zeros(nr,nr); %Has backbone H-bond?
%Over every residue pair i,j...
for i = 1:nr
    for j = 1:nr
        %Only do if i >= j + min
        if i >= j + mindist
            %Get residue data. Maybe preseparate? eh
            tmpi = atmnoh([atmnoh.resSeq] == i);
            tmpj = atmnoh([atmnoh.resSeq] == j);
            
            %Get XYZ data of these two residues
            xi = [tmpi.X];
            yi = [tmpi.Y];
            zi = [tmpi.Z];
            xj = [tmpj.X];
            yj = [tmpj.Y];
            zj = [tmpj.Z];
            
            %Create single-dim distances between all pairs
            xx = bsxfun(@minus, xi(:), xj(:)');
            yy = bsxfun(@minus, yi(:), yj(:)');
            zz = bsxfun(@minus, zi(:), zj(:)');
            
            %Calculate distance between all pairs
            rr = (xx.^2 + yy.^2 + zz.^2) .^.5;
            
            %Find closest pair
            mind = min(rr(:));
            
            %Count contacts
            ncon = sum( rr(:) < dmax );
            
%             %Check for backbone H-bond: Let's call this a contact between backbone residues, so AtomName of CA, C, or N
%             [r,c] = find( rr < dmax );
%             ani = {tmpi(r).AtomName};
%             anb = {tmpj(c).AtomName};
%             bbchk = @(x) strcmp(x, 'CA') || strcmp(x, 'C') || strcmp(x, 'N');
%             hasbb = any( cellfun(bbchk, ani) & cellfun(bbchk, anb) );
            
            %Save. Save both i,j and j,i
            dmap(i,j) = mind; dmap(j,i) = mind;
            nhc(i,j) = ncon; nhc(j,i) = ncon;
%             isbb(i,j) = hasbb; isbb(j,i) = hasbb;
        end
    end
end

%Save HELIX and SHEET info. Use it for isbb? Sheets aren't having isbb -- maybe bc it's an NMR structure?


out.dmap = dmap;
out.nhc = nhc;
% out.isbb = isbb; Eh replace this with ChimeraX's H-bonds tool, below

%Try loading hbonds if .txt file with same name exists
[p, f, ~] = fileparts(infp);
hbpf = fullfile(p, [f '.txt']);
if exist(hbpf, 'file')
    hb = importHbonds(hbpf);
    %Array size might be different, cut to match
    isbb = zeros(nr);
    if length(hb) > nr
        isbb = hb(1:nr, 1:nr);
    else
        nb = length(hb);
        isbb(1:nb, 1:nb) = hb;
    end
    out.isbb = isbb;
    
%     %And add ishelix field from HELIX pdb comments. Else calculate via dssp command in Chimera, e.g.
%     if isfield(dat, 'Helix')
%         %Hm this may lose the edgemost helix residues... probably bad? just take any isbb within 3aa?
%         hlx = dat.Helix;
%         ishel = zeros(nr);
%         for i = 1:length(hlx)
%             %Let's... assign isbb's that are both in HELIX = helical reisudes?
%             seqrng = hlx(i).initSeqNum:hlx(i).endSeqNum;
%         end
%     end
    %Eh just use any bb hb with distance <=4
    heldist = 4;
    ishelix = triu(tril(isbb, heldist), -heldist); %Grabs -heldist:heldist diagonals
    out.ishelix = ishelix;
    
    out.eij = calcE(out);
end






