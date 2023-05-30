
%------------------------------------------------------------------
% cgDNA, version 1.0.1 (2014), examples of free energy calculations.  
%------------------------------------------------------------------
% This program predicts the free energy difference between two
% configurations of a molecule of B-form DNA of a given sequence in
% standard environmental conditions. The free energy difference is
% provided in units of kbT.  Note that the parameter set
% cgDNAparamset1 was extracted from MD simulations at 300K. The
% model free energy value in kcal/mol can therefore be obtained by
% multiplying by (0.0019872041 * 300.0).
%
%
% Input: 
%
%   S          sequence along reference strand
%
%   config1    configuration coordinate vector
%              in non-dimensional Curves+ form
%              [size N x 1]
%
%   config2    configuration coordinate vector
%              in non-dimensional Curves+ form
%              [size N x 1]
% 
%   params     free energy parameter set 
%
%
% Output: 
%
%   deltaU     free energy difference of config2
%              relative to config1 in units of kbT.
%
%
%   where N = 12*nbp - 6 and nbp is the length of the 
%   sequence S (number of basepairs). 
%
%
% Note:
%
%    Any of the variables S, config1 and config2 can 
%    be input directly, or can be read from a file.
%    For example, a sequence along with a configuration 
%    can be read from a .lis file; such a file can be
%    obtained by running Curves+ on a .pdb file, and 
%    the configuration so obtained would be in 
%    standard (dimensional) Curves+ form, which could 
%    then be converted to non-dimensional form.  
%
%    In general, any formatted coordinate set that 
%    Curves+ can read to produce a valid .lis output 
%    file, can therefore be read into cgDNA (see also
%    "help parseLis"). The file "examples/1bna.lis"
%    used in the second example below was obtained
%    by running: 
%
%    /Users/RL/Code/Cur+ <<!
%    &inp file=1bna.pdb,
%    lis=1bna, 
%    lib=/Users/RL/Code/standard, &end
%    2 1 -1 0 0
%    1:12
%    24:13
%    !
%  
%    provided your Curves+ installation is in 
%    /Users/RL/Code/.  For more information about 
%    Curves+ and its usage, see  
%    http://gbio-pbil.ibcp.fr/Curves_plus.
%    The file "1bna.pdb" was downloaded from the 
%    RCSB PDB (http://www.rcsb.org/pdb). 
%
%
% If you find this code useful, please cite:
%
% D. Petkeviciute, M. Pasi, O. Gonzalez and J.H. Maddocks. 
%  cgDNA: a software package for the prediction of 
%  sequence-dependent coarse-grain free energies of B-form 
%  DNA. Nucleic Acids Research 2014; doi: 10.1093/nar/gku825. 
%
%-----------------------------------------------------------


%% Load parameter set
params = load('cgDNAparamset1.mat');


%% EXAMPLE 1.  Free energy calculation in which we directly 
%% specify S, use the ground-state as config1, and use a 
%% random perturbation of the ground-state as config2.

%-- Prescribe sequence
S = 'CGCGAATTCGCG';
fprintf('Example1: Using sequence %s\n', S);

%-- Get ground-state in non-dimensional Curves+ form
[nondimshapes, stiff] = constructSeqParms(S, params);

%-- Define config1 and config2
sd = .1;
config1 = nondimshapes; %ground-state
config2 = config1 + sd*randn(size(config1)); %random change
fprintf(['Example1: applying a Gaussian random perturbation (mean = 0, ' ...
         ' s.d. = %.2f) to the non-dimensional ground-state configuration\n'], sd);

%-- Compute deltaU 
deltaU = freeEnergyDiff(config1,config2,nondimshapes,stiff);
fprintf('Example1: deltaU = %5.1f kbT (or %5.1f kcal/mol at 300K)\n', deltaU, deltaU * 0.0019872041 * 300.0);


fprintf('\n');


%% EXAMPLE 2.  Free energy calculation in which we read a
%% sequence S and a (dimensional) configuration config0 
%% from a .lis file, and then use the non-dimensional form 
%% of config0 as config1, and use a modification of config0 
%% as config2.

%-- Read sequence and configuration from .lis file
lis = 'examples/1bna.lis';
fprintf('Example2: Reading input from <%s>\n', lis);
[config0, S] = parseLis(lis);
    
%-- Get ground-state in non-dimensional Curves+ form
[nondimshapes, stiff] = constructSeqParms(S, params);

%-- Define config1 
config1 = cur2nondim(config0); %non-dimensional form

%-- Define config2 by adding 5-degrees to Twist between 
%-- 4th and 5th basepair of config0

[Buckle_Propeller_Opening,...
    Shear_Stretch_Stagger,...
          Tilt_Roll_Twist,...
         Shift_Slide_Rise] = vector2shapes(config0); 

Tilt_Roll_Twist(4, 3) = Tilt_Roll_Twist(4, 3) + 5.0;
fprintf(['Example2: Adding 5 degrees Twist at the 4th junction ' ...
         'of the ground-state configuration\n']);

mod_config0 =...
     shapes2vector(Buckle_Propeller_Opening,...
                   Shear_Stretch_Stagger,...
                   Tilt_Roll_Twist,...
                   Shift_Slide_Rise);

config2 = cur2nondim(mod_config0); %non-dimensional form

%-- Compute deltaU 
deltaU = freeEnergyDiff(config1,config2,nondimshapes,stiff);
fprintf('Example2: deltaU = %5.1f kbT (or %5.1f kcal/mol at 300K)\n', deltaU, deltaU * 0.0019872041 * 300.0);

