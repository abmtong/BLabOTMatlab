function [out, tf] = flipconsensus(datmtx)
%Finds a consensus that maximizes the alike-ness of the data by flipping them or not
%Input: matrix of data, column vector per data


%Let's shift datmtx to have mean zero
datmtx = datmtx - mean(datmtx(:));
len = size(datmtx, 2);

%Generate average
curavg = mean(datmtx, 2);

%And iterate
curtf = zeros(1, size(datmtx, 2));
maxiter = 1e2; %Upper limit for iteration, should only need to do a few times, but could get caught in a loop
niter = 0;
while true
    %Test each alignment
    reg = sum( bsxfun(@times, curmtx,        curavg(:) ), 1);
    flp = sum( bsxfun(@times, curmtx, flipud(curavg(:))), 1);
    
    
    %Flip curtf if reg < flp : this is xor
    newtf = reg > flp;
    
    %Check if we're done: if newtf = curtf
    if newtf == curtf || niter > maxiter;
        break
    end
    
    %Else let's calc a new average
    
    %Apply flipping
    curmtx = datmtx;
    for i = 1:len
        if curtf(i)
            curmtx(:,i) = flipud( curmtx(:,i) );
        end
    end
    %And average
    curavg = mean( curmtx, 2 );
    
    niter = niter + 1;
end

out = curavg;
tf = newtf;