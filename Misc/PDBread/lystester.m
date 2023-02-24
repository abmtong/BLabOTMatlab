function out = lystester(inpdb)

%Test RMSD processing for Lysozyme

%inpdb is a stack of PDBs (MD frames) aligned to a region of interest (last one)

roi = [96, 124]; %Region of interest, residues

% nf = 500; %number of frames

%Just do CA position for now...?
tfca = strcmp(inpdb.atomName, 'CA');
nn = inpdb.resNum(tfca);
xx = inpdb.X(tfca);
yy = inpdb.Y(tfca);
zz = inpdb.Z(tfca);

%Split by rollover
% nc = cell(1,nf);

%Quick n dirty model identifier, as the export doesn't have one
mdl = cumsum( diff([inf nn]) < 0 ) ;
nf = max(mdl)-1;
xc = cell(1,nf);
yc = cell(1,nf);
zc = cell(1,nf);

tfroi = nn >= roi(1) & nn <= roi(2);
for i = 1:nf
    %Extract ROI x,y,z coords
    tmptf = mdl == i & tfroi;
    xc{i} = xx(tmptf);
    yc{i} = yy(tmptf);
    zc{i} = zz(tmptf);
end

%tf+1th model is the reference
tmptf = mdl == (nf+1) & tfroi;
xref = xx(tmptf);
yref = yy(tmptf);
zref = zz(tmptf);

%RMSD to reference
nr = roi(2)-roi(1)+1;
rms = zeros(1, nr);
for i = 1:nr
    %Get xyz coords of these CAs
    xcr = cellfun(@(x) x(i), xc);
    ycr = cellfun(@(x) x(i), yc);
    zcr = cellfun(@(x) x(i), zc);
    
    %Get distances
    rsq = (xcr - xref(i)).^2 + (ycr - yref(i)).^2 + (zcr - zref(i)).^2;
    rms(i) = sqrt(mean(rsq));
end
out = rms;

figure, plot(out)







