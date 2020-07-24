function Xb = GheCalibrate_MakeBlocks(X, nBlock)
% This function breaks the vector X into blocks (nBlock in total). This
% suppresses noise in power spectra and makes fitting faster.
%
% USE: Xb = GheCalibrate_MakeBlocks(X,nBlock)
%
% Gheorghe Chistol, 3 Feb 2012

    nbin = floor(length(X)/nBlock);
    Xb   = NaN*zeros(nbin, 1); %preallocate room/memory for faster execution

    for i = 1 : nbin,
        Xb(i) = GheCalibrate_MeanNaN( X((i-1)*nBlock+1 : i*nBlock) );
    end;

end