%{
Bead Delay
Seems to be about 80 data points (or 80/decimate), might be worth implementing
Will tank computational performance of findStepHist, but maybe for the better
%}

%{
Contour vs Extension


%}

%{
Calculating Force/Contour/Extension from the 8 voltage channels {AY,BY,AX,BX,MY,MX,SA,SB}
B is fixed trap, A steerable
For [A,B] x [X, Y]:
    normAX = AX/SA
    TrapExtAX = (normAX - offsetAX) * alphaAX
        Note: Subtracting offset isn't strictly necessary, as we'll be taking a differential force
    ForAx = TrapExtAx * kappaAX
For [X, Y]:
    ForX = (ForAX - ForBX) /2 %Average force - one feels the negative force of the other
For = sqrt(ForX^2 + ForY^2)
Ext = sqrt( TrapExtX^2 + TrapExtY^2 ) - ( BeadRadiusA + BeadRadiusB )
Con = Ext/XWLC(F, P, S)
%}

%{
Timing Test Results

For low-level actions like @var consider writing a C implementation C_var for speed increase
@bsxfun beats any other matrix operation that accomplishes the same goal (cf @repmat, for loop, etc)
@zeros is the fastest preallocator (cf @ones, @inf, 0*matrix, etc)

%}


%{
Trace Class? Essentially stepdata struct but with more options, less typing
props
 contour, force, ext, ...
 filter props ( {@filterfnc wid dec} ) - save or 
 options [calc with contour, ...]
methods
 calc contour (P, S)
 filter
 stepfind
%}





