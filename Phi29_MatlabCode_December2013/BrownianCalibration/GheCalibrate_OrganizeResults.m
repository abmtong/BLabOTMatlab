function [Result cal] = GheCalibrate_OrganizeResults(Result,Def,Path,File)
% This function organizes the results from our new fancier calibration into
% the same data sctructure as the old calibration from Jeff Moffitt. This
% way we maintain consistency and backward compatibility.
%
% USE: [Result cal] = GheCalibrate_OrganizeResults(Result,Def,Path,File)
%
% Gheorghe Chistol, 9 Feb 2012
    
    cal.path        = Path;
    cal.file        = File;
    cal.stamp       = now; %timestamp
    cal.date        = date;
    cal.beadRadiusA = Def.bRadiusA; %radius
    cal.beadRadiusB = Def.bRadiusB; %radius
    cal.dragCoeffA  = 6*pi*Def.wViscosity*Def.bRadiusA; %drag coeff
    cal.dragCoeffB  = 6*pi*Def.wViscosity*Def.bRadiusB; %drag coeff

    Da = Def.kB*Def.wTemp/cal.dragCoeffA; %the expected D coefficient for bead A
    Db = Def.kB*Def.wTemp/cal.dragCoeffB; %the expected D coefficient for bead B

    cal.alphaAX = sqrt(Da/Result.AX.D); %conversion coefficient for the detector, converts normalized volts to nm
    cal.alphaAY = sqrt(Da/Result.AY.D);
    cal.alphaBX = sqrt(Db/Result.BX.D);
    cal.alphaBY = sqrt(Db/Result.BY.D);
    cal.kappaAX = 2*pi*cal.dragCoeffA*Result.AX.fc; %2*pi*gammaBead*Fcorner
    cal.kappaAY = 2*pi*cal.dragCoeffA*Result.AY.fc;
    cal.kappaBX = 2*pi*cal.dragCoeffB*Result.BX.fc;
    cal.kappaBY = 2*pi*cal.dragCoeffB*Result.BY.fc;
    
    %update Result with these values, for convenience
    Result.AX.TrapStiffness = cal.kappaAX;
    Result.AY.TrapStiffness = cal.kappaAY;
    Result.BX.TrapStiffness = cal.kappaBX;
    Result.BY.TrapStiffness = cal.kappaBY;
    Result.AX.DetectorCalib = cal.alphaAX;
    Result.AY.DetectorCalib = cal.alphaAY;
    Result.BX.DetectorCalib = cal.alphaBX;
    Result.BY.DetectorCalib = cal.alphaBY;

end