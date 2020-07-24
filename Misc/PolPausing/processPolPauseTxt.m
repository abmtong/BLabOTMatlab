function processPolPauseTxt(txtfp)
%Reads a pol-formatted text file to turn .dat triplet to .mat
%Text file is in .\info.txt , data files are in .\mmddyy\mmddyy_NNN.dat

if nargin < 1
    [f, p] = uigetfile('*.txt');
    if ~p
        return
    end
    txtfp = fullfile(p,f);
end

%Polymerase text file has [mmddyy] [cal] [off] [data] [t0] [t1]

%Read text file. All numbers
fid = fopen(txtfp);
dat = textscan(fid, '%d %d %d %d %f %f');
fclose(fid);
nmdys = dat{1};
ncals = dat{2};
noffs = dat{3};
ndats = dat{4};
ncrp1 = dat{5};
ncrp2 = dat{6};

path = fileparts(txtfp);
%Add path to timeshare processing code
addpath(sprintf('%s\\..\\Timeshare Processing\\', fileparts(mfilename('fullpath'))))
for i = 1:length(nmdys);
    %Create paths
    rootpath = sprintf('%s\\%06d\\%06d', path, nmdys(i), nmdys(i) );
    fpcal = sprintf('%s_%03d.dat', rootpath, ncals(i) );
    fpoff = sprintf('%s_%03d.dat', rootpath, noffs(i) );
    fpdat = sprintf('%s_%03d.dat', rootpath, ndats(i) );
    %Run tsprocess
    tsprocess_batch('single', fpcal, fpoff, fpdat);
    
    %Save crop file
    [~,f,~] = fileparts(fpdat);
    cropfp = sprintf('%s\\CropFiles\\%s.crop', rootpath, f);
    cropp = fileparts(cropfp);
    %Create the folder, if it doesn't exist
    if ~exist(cropp, 'dir')
        mkdir(cropp)
    end
    %Write the crop
    fid = fopen(cropfp, 'w');
    fwrite(fid, sprintf('%f\n%f', ncrp1(i), ncrp2(i) ));
    fclose(fid);
end