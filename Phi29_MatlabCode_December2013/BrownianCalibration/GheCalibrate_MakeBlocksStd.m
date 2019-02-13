function StdXb = GheCalibrate_MakeBlocksStd(X, nBlock)
% This function breaks the vector X into blocks (nBlock in total) and
% calculates the standard deviation in each block. So it's very
% closely related to GheCalibrate_MakeBlocks() 
%
% USE: StdXb = GheCalibrate_MakeBlocksStd(X, nBlock)
%
% Gheorghe Chistol, 3 Feb 2012

    nbin = floor(length(X)/nBlock);
    StdXb   = NaN*zeros(nbin, 1); %preallocate room/memory for faster execution

    for i = 1 : nbin,
        StdXb(i) = GheCalibrate_StdNaN( X((i-1)*nBlock+1 : i*nBlock) );
    end

end