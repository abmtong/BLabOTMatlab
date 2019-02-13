%Trap Conversion (nm/V)
%{
The traps are controlled by passing the mirror a voltage, which we need to convert to distance
Note that the total range of the trap is rectangular, not square, so X and Y have separate conversions.
This is done by taking a picture of a e.g. 10um graticle in place of the chamber
By counting pixels, we can find a conversion of pixels to um.
Next, trap two beads, and slowly move the traps together while taking pictures at each step
Find the distances between the beads (find them via boundary detection), and find a conversion between V and pixels
Divide the two to get the conversion factor.
The one measured by Ghe in ~2011 and Alex in 2017 were nearly identical, so it probably doesn't need to be measured again.
%}

%Trap Offset (V)
%{
Trap A doesn't fall on (0,0) in mirror-space. As of writing(9/27/17), it falls around (1.4,
You can measure the position of TrapA simply by finding the point where a trapped bead stays still when toggling traps
You can scan the trap in a grid about this rough position to find a more precise value (the QPD outputs should peak at the overlap)
%}

%Misc Notes
%{
The mirror doesn't quite get set to what we set it to
MirrorRead = MirrorSent - (8.244e-4*MirrorSent -33.397e-4)
This difference goes to zero around 4.075V, which is around where we do experiments, which is convenient
We don't usually use MirrorSent, so this isn't often a concern, but know it's there.
%}