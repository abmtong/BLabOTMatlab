%JSsimFoldingNotes
%{
Notes on implementing the Jacobs-Shakhnovich protein folding simulations
http://dx.doi.org/10.1016/j.bpj.2016.06.031

Based on crystal structure contact map and basic residue-level coarse-grained simulation

Basically, creating a native contact yields some energy X, and loses some entropy Y

Native contact = any 4a contact between heavy atoms (i.e. non H)
Contact must be farther than a Kuhn length (2aa) apart [so min dist = 3aa]

There are some restrictions on what are allowable states:
 They divide up the graph into 'connected components' (CCs), a subset of residues that have all native contacts formed
 Also, in a CC, a gap in sequence must be at least b residues apart
  e.g. for a B hairpin, you can't have a less than b-residue--sized loop on the loop side
  i.e., in a CC, any residues separated by b or fewer residues are in the CC
  
Loops 


Free Energy
Eqn 1
F/kT = sum over CCs{ (N_residues_in_cc -1 ) * mu/kT + sum over residue pairs( 1(c,u,v) epsilon(u,v) /kT) } - deltaS1/k
  mu/T is the configuration entropy lost per residue
  epsilon(u,v) is the per-residue pair energetic contact. 1(c,u,v) is the isa contact selection function.
  deltaS1 is the entropic penalty of closed loops of noninteracting residues, where:
Eqn 2
deltaS1/kb = sum over all loops{ let l = N_noninteracting_residues_in_loop:
     if l <= b, = -l mu/kT
     if l > b, -b mu/kT - d/2[ ln(l/b) + r(loop)^2/bbl ]
          r(loop) is the distance between the fixed ends of the loop, d = 3 (spatial dimension)
            **r is in units of backbone bond length, r=0 if loop ends are contacting

Numbers
  mu = 2kT, can do 1.5 to 2.5kT
  Energy epsilon(u,v) is number of heavy-atom contacts + main-chain H-bond term 
  Energy epsilon(u,v) = - (5/8 if helical contact, 1 if not) * [n_heavy_contacts + 16*has_h_bond]
  1/kT is chosen to have a 'fixed FE difference between F and U'

Calculation
  'Monte Carlo integration'
  Basically, quick/efficient random sampling of conformation space
 Start with a basic chain (all microstates equal probability) and adjust to get proper prob.s

 Start with one CC c, find list of addable verticies








%}