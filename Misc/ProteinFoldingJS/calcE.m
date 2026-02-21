function out = calcE(inst)
%Calculates residue contact energy ('epsilon_uv' in paper, we'll say eij)

%Apply interaction distance minimum

%eij =  - (5/8 if helical contact, 1 if not) * [n_heavy_contacts + 16*has_h_bond]

mind = 3; %Minimum interaction distance

ahelix = 5/8; %Alpha helix destabilization factor
abbhb = 16; %Backbone H-bond relative energy
%I guess a generic heavy atom contact is worth 1kT?

%Convert ishelix (0, 1) -> helix energy multiplier (1, ahelix)
ehelix = (inst.ishelix == 0) + (inst.ishelix == 1) * ahelix;

out = - ehelix .* ( inst.nhc + abbhb * inst.isbb ); %Interaction energy, kT

%Enforce minimum interaction distance
out = out - triu(tril(out, mind-1), -mind+1);




