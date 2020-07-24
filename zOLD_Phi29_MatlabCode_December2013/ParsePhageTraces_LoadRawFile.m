function data = ParsePhageTraces_LoadRawFile(fsamp,RawFileName,RawFilePath)
% Reads binary data file, and outputs to structure "data". I modified
% Jeff's original file to be able to read extremely large files (300+Mb).
% This is done via memmapfile, which maps the file without loading it,
% enabling you to access it as if it were a matrix, indexing only the stuff
% you care about.
% 
% USE: data = MakeOffsetFiles_LoadRawFile(fsamp,RawFileName,RawFilePath)
%
% Gheorghe Chistol, 09 Feb 2012 

data.path = RawFilePath;
data.file = RawFileName;
data.date = date;

%% Reading the new way using memapfile
temp = memmapfile([RawFilePath filesep RawFileName], 'Format', 'single');
L = length(temp.Data); %this is how many values are in the file
N = L/8; %How many time-points are in the file; 8 values for each time-point
Ind1 = linspace(1, L-7, N); %the index for Vay data
Ind2 = linspace(2, L-6, N); %the index for Vby data
Ind3 = linspace(3, L-5, N); %the index for Vax data
Ind4 = linspace(4, L-4, N); %the index for Vbx data
Ind5 = linspace(5, L-3, N); %the index for Mx data
Ind6 = linspace(6, L-2, N); %the index for My data
Ind7 = linspace(7, L-1, N); %the index for Sa data
Ind8 = linspace(8, L  , N); %the index for Sb data

%% Assign data according to its index table and
% swap bytes from little-endian to big-endian
data.A_Sum = swapbytes(temp.Data(Ind7)); clear Ind7;
data.B_Sum = swapbytes(temp.Data(Ind8)); clear Ind8;
data.A_X = swapbytes(temp.Data(Ind3))./data.A_Sum; clear Ind3; %normalize A_X voltage by A_Sum
data.A_Y = swapbytes(temp.Data(Ind1))./data.A_Sum; clear Ind1; %normalize A_Y voltage by A_Sum
data.B_X = swapbytes(temp.Data(Ind4))./data.B_Sum; clear Ind4; %normalize B_X voltage by B_Sum
data.B_Y = swapbytes(temp.Data(Ind2))./data.B_Sum; clear Ind2; %normalize B_Y voltage by B_Sum
data.Mirror_X = swapbytes(temp.Data(Ind5)); clear Ind5;
data.Mirror_Y = swapbytes(temp.Data(Ind6)); clear Ind6;
data.time     = (0:N-1)/fsamp;

%    Here's the old way of reading data using FREAD
%    h = fopen([startpath file{j}]);
%    m = fread(h,1e10,'float32','ieee-be');
%    %n=m((1+header):(size(m)-header));
%    l = reshape(m,8,length(m)/8);
end