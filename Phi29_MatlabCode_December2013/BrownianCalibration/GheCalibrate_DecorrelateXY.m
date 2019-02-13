function [Px, Py, X, Y, b, c, Report] = GheCalibrate_DecorrelateXY(X, Y, T, f, Px, Py, fDecorrStart, fDecorrEnd, fNyq, nBlock, nFitIter, TolX, Report)
% This function is based on the TweezerCalib2.1 decorr_xy script, but is
% now enclosed and more compact. Basically, it removes the cross-talk
% between X and Y channels for a given detector. For more details, please
% read the article "MatLab program for precision calibration of optical
% tweezers", Computer Physics Communications 159 (2004) 225–240, Iva Marija
% Tolic-Nørrelykke, Kirstine Berg-Sørensen, Henrik Flyvbjerg
%
% USE: [Px, Py, X, Y, Report] = GheCalibrate_DecorrelateXY(X, Y, T, f, Px, Py, fDecorrStart, fDecorrEnd, fNyq, nBlock, nFitIter, TolX, Report)
%
% Gheorghe Chistol, 2 Feb 2012

    % Calculate Pxy - power of the cross-talk between the channels
    delta_t = 1./(2.*fNyq);
    Pxy = real(delta_t*fft(X) .* conj(delta_t*fft(Y))) / T;
    Pxy = Pxy(f <= fNyq);
    
    % Choose data to be fitted
    ind  = (f > fDecorrStart & f <= fDecorrEnd);
    fd   = f(ind);   %range of frequency to be used for decorrelation
    Pxd  = Px(ind);  %%subscript 'd' stands for 'decorrelation'  
    Pyd  = Py(ind); 
    Pxyd = Pxy(ind); 

    % Bin Px, Py, Pxy into bins/blocks containing nblock points in each
    fb   = GheCalibrate_MakeBlocks(fd,   nBlock);   %subscript 'b' stands for 'binned'  
    Pxb  = GheCalibrate_MakeBlocks(Pxd,  nBlock); %we want this stuff in a column, not in a row 
    Pyb  = GheCalibrate_MakeBlocks(Pyd,  nBlock);
    Pxyb = GheCalibrate_MakeBlocks(Pxyd, nBlock);

    % Fit power spectra to find the decorrelation parameters 'b' and 'c'
    % Guess Parameters [b0 c0] = [.1 .1]
    [parameters, RESNORM, RESIDUAL, JACOBIAN] = GheCalibrate_FitNonlin(@GheCalibrate_MinCorr, [0.1 0.1], TolX, nFitIter, Pxb, Pyb, Pxyb);

    % M = GheCalibrate_MinCorr(parameters,Pxb,Pyb,Pxyb);
    %add decorrelation parameters to the report
    Report = [ Report '......Decorrelation Parameters: b=' num2str(parameters(1) ,'%5.2f') ...
                                                    ', c=' num2str(parameters(2) ,'%5.2f') '/n'];
    
    b       = parameters(1); 
    c       = parameters(2);                              
    Px1     = Px + 2*b*Pxy + b^2*Py;          %Px with cross-talk removed
    Py1     = Py + 2*c*Pxy + c^2*Px;          %Py with cross-talk removed
    Px1y1   = (1 + b*c) .* Pxy + c*Px + b*Py; %Pxy with cross-talk removed

    % now block data in Px1, Py1, Px1y1
    Px1b   = GheCalibrate_MakeBlocks(Px1,   nBlock);
    Py1b   = GheCalibrate_MakeBlocks(Py1,   nBlock);
    Px1y1b = GheCalibrate_MakeBlocks(Px1y1, nBlock);
    

%     %plot the results of removing cross-talk    
%     figure; 
%     set(gcf,'Numbertitle','off','Name','Elimination of crosstalk'); hold on;
%     h = title('Eliminating cross-talk between channels'); set(h,'Fontweight','Bold');

    % Update the Px and Py powers after removing cross-talk
    Px = Px1;
    Py = Py1;
    
    % Also update data for position:
    X1 =  X + b*Y;
    Y1 =  Y + c*X;
    X  = X1;
    Y  = Y1;
end