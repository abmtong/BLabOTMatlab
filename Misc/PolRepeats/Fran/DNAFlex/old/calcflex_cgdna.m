function out = calcflex_cgdna(seq)
%Uses the 'cgDNA' package to predict stiffness
% Reference: http://dx.doi.org/10.1063/1.4789411

%They got their values by fitting to MD simulations
% It seems to be on the resolution of dinucleotides, so can simplify to a matrix?

%The output is a stiffness matrix (in the model sense) of the 12 motions:
% Buckle/Propeller/Opening/Shear//Stretch/Stagger (dynamics of bases in one bp)
% and Tilt/Roll/Twist/Shift/Slide/Rise (dynamics across adjacent bps)

%The one-bp values takes into account the two dinucleotides that flank it; but the dinucs are just dinuc values
% So, the flexibility should be distillable into one matrix: take one of the tilt/roll/twist values? A combination?

%Add folder, held in subdir ./cgDNA
addpath('./cgDNA/')

%-------------------------------------------------------
% cgDNA, version 1.0.1 (2014), main program.  
%-------------------------------------------------------
% This program predicts the ground-state conformation 
% and stiffness (or inverse covariance) matrix of a 
% molecule of B-form DNA of any given sequence in 
% standard environmental conditions. 
%
%
% Input: 
%
%   sequence  sequence along reference strand.
%
%
% Output: 
%
%   nondimshapes  ground-state coordinate vector 
%                 in non-dimensional Curves+ form
%                 [size N x 1]
%
%   stiff         ground-state stiffness matrix
%                 in non-dimensional Curves+ form
%                 [size N x N]
%
%   curshapes     ground-state coordinate vector in
%                 standard (dimensional) Curves+ form
%                 [size N x 1]
%
%   basepair      structure with reference point and
%                 frame for each base on each strand
%                 (see "help frames"). [size nbp x 1]
%
%   Buckle_Propeller_Opening  list of intra-basepair
%                             rotational coords 
%                             along molecule in
%                             standard Curves+ form
%                             [size nbp x 3]
%
%   Shear_Stretch_Stagger     list of intra-basepair
%                             translational coords 
%                             along molecule in
%                             standard Curves+ form
%                             [size nbp x 3]
%
%   Tilt_Roll_Twist           list of inter-basepair
%                             rotational coords along
%                             molecule in standard
%                             Curves+ form
%                             [size (nbp-1) x 3]
%
%   Shift_Slide_Rise          list of inter-basepair
%                             translational coords 
%                             along molecule in 
%                             standard Curves+ form
%                             [size (nbp-1) x 3]
% 
%   where nbp is the length of S (number of basepairs) 
%   and N = 12*nbp - 6.
%   
%-------------------------------------------------------


% Define sequence along reference strand, minimum 2 bases
% seq = 'CGCGAATTCGCG';

% Load parameters from parameter file.
params = load('./cgDNA/cgDNAparamset1.mat');

% Construct ground-state coords and stiffness matrix in non-dimensional Curves+ form.
[nondimshapes, stiff] = constructSeqParms(seq, params);  
curshapes = nondim2cur(nondimshapes);

% % Write standard Curves+ coords to file
% coordinateOutputFile = 'shapes.txt';
% fprintf('Saving coordinates to file <%s>... \n', coordinateOutputFile);
% printShapeParms(curshapes, sequence, coordinateOutputFile);  

% Construct reference frame for each base.  
basepair = frames(nondimshapes);   


%% Construct PDB file of atomic coordinates 
% % for each base and save results in a file.
% PDBOutputFile = 'base_atoms.pdb';
% fprintf('Saving coordinates to PDB file <%s>... \n', PDBOutputFile);
% makePDB(sequence, basepair, PDBOutputFile);


% %% Plot standard Curves+ coords to screen
% fprintf('Making coordinate plots... \n');
% plotShapeParms(curshapes, sequence);  


% Construct list of Curves+ coordinates arranged by type for later use if desired
[Buckle_Propeller_Opening,...
 Shear_Stretch_Stagger,...
 Tilt_Roll_Twist,...
 Shift_Slide_Rise] = vector2shapes(curshapes); 

% %% End of program message
% fprintf('Done. See %s and %s for output.\n', coordinateOutputFile, PDBOutputFile);


%Convert stiffness matrix to simple output
%Take diagonal; also un-sparse it
tmp = full(diag(stiff));
%Pad with 6 zeroes, since there are N 1bp terms and (N-1) 2bp terms
% And reshape to 12xn matrix
tmp = reshape( [tmp(:)' zeros(1,6)], 12, [] )';

%Decide on what to use as 'stiffness', for now just output the whole mtx
out = tmp;







