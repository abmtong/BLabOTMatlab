%{
Forces of two beads should be equal
They are not, why?

A bead that is 10% larger than we think has its force underestimated by 5% (by sqrt ratio)

Seems randomly distributed ish

If we see one larger than the other, is there a significantly better solution than taking their average?

If the bead size dist is flat: triangular dist
 Expected difference is 33% of total range

If the bsd is normal: Normal dist.
 Expected difference is 1.13*sd, assumedly total range is ~4*sigma, so 29% of range (about the same)

Does there exist systematic error, though? (b/c one trap is stiffer than the other, errors may affect it more than others)

Probably impossible without a reference force/length

SEEMS DOUBTFUL


Suppose we have alpha/k distributions for the beads, per trap
 dC = 6*pi*wV*ra
 alpha = sqrt( kT /dC /Dfit )
 kappa = 2 *pi *dC *Fcfit

Both have a dependence on bead size, through dC, though one is ^1, other ^(-.5)
 Could get an mle of the bead size? does alpha vs. k look like x^1/2?
For same beads, different days, alpha vs. k looks linear (x^-.5 to first order, probably), normally(ish) distributed

%}