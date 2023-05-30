
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
%
%
% Main output files: 
%
%   shapes.txt      text file with ground-state coordinates 
%                   in standard Curves+ form
%
%   base_atoms.pdb  PDB file of ground-state structure.
%
%
%
% If you find this code useful, please cite:
%
% D. Petkeviciute, M. Pasi, O. Gonzalez and J.H. Maddocks. 
%  cgDNA: a software package for the prediction of 
%  sequence-dependent coarse-grain free energies of B-form 
%  DNA. Nucleic Acids Research 2014; doi: 10.1093/nar/gku825.
%
%-------------------------------------------------------


%% Define sequence along reference strand, minimum 2 bases
sequence = 'CGCGAATTCGCG';
%% or read the sequence from a plain text with the sequence 
% or from a FASTA format file (type <help parseFasta> for more
% details):
%
% sequence = parseFasta('sequence.txt');

%% Echo sequence to screen
fprintf('Working on sequence %s \n',sequence);


%% Load parameters from parameter file.
params = load('cgDNAparamset1.mat');


%% Construct ground-state coords and stiffness matrix
% in non-dimensional Curves+ form.
fprintf('Constructing ground-state structure... \n');
[nondimshapes, stiff] = constructSeqParms(sequence, params);  


%% Convert ground-state coords to standard Curves+ form
fprintf('Converting coordinates... \n');
curshapes = nondim2cur(nondimshapes);


%% Write standard Curves+ coords to file
coordinateOutputFile = 'shapes.txt';
fprintf('Saving coordinates to file <%s>... \n', coordinateOutputFile);
printShapeParms(curshapes, sequence, coordinateOutputFile);  


%% Construct reference frame for each base.  
fprintf('Constructing base frames... \n');
basepair = frames(nondimshapes);   


%% Construct PDB file of atomic coordinates 
% for each base and save results in a file.
PDBOutputFile = 'base_atoms.pdb';
fprintf('Saving coordinates to PDB file <%s>... \n', PDBOutputFile);
makePDB(sequence, basepair, PDBOutputFile);


%% Plot standard Curves+ coords to screen
fprintf('Making coordinate plots... \n');
plotShapeParms(curshapes, sequence);  


%% Construct list of Curves+ coordinates 
% arranged by type for later use if desired
[Buckle_Propeller_Opening,...
 Shear_Stretch_Stagger,...
 Tilt_Roll_Twist,...
 Shift_Slide_Rise] = vector2shapes(curshapes); 

%% End of program message
fprintf('Done. See %s and %s for output.\n', coordinateOutputFile, PDBOutputFile);
