function WiggleCal_WriteTestCalFile(X,Y,FileName)
% Write voltages X,Y to a test Calibration file that can be used by
% TweezerCalib2.0
%

%write X Y 1 in each line of the file

Data = [X' Y' double(ones(size(X)))'];

fid = fopen(FileName,'w');
fprintf(fid,'%12.8f %12.8f %12.8f\n',Data');
fclose(fid);
