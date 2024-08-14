function [out, meta] = loadREMD(inp)
%Loads a replica exchange MD simulation
%Basically, if you follow the REMD tutorial from Amber it'll create the required files

if nargin < 1
    inp = uigetdir;
end

%Filenames:
pdbnam = 'ala10.pdb'; %Name of the source pdb. Using the default 'ala10' for everything, even if it's not ala10 (!!!)
tmpnam = '99_temperatures.dat'; %Temperatures file
leapin = '99_leap.in'; %LEaP file
mdin = '99_remd.mdin'; %REMD mdin


%Filename sprintf strings
mdoutstr = 'remd.mdout.%03d'; %sprintf string for mdout files
trajstr = 'remd.reptraj.%03d.dcd'; %sprintf string for .dcd trajectories
% trajstr = 'remd.Ttraj.%0.2f.dcd'; %sprintf string for .dcd trajectories

%MD params
% dcdout = 500; %Timesteps per output to dcd file

%Load pdb
pdb = pdbread( fullfile(inp, pdbnam) );

%Get temperature list
fid = fopen(fullfile(inp, tmpnam));
t = textscan(fid, '%f');
fclose(fid);
t = t{1}';

%Add matdcd-1.0 folder
thisp = fileparts(mfilename);
addpath( fullfile(thisp, 'matdcd-1.0') );

len = length(t);
out = cell(1,len);
%For each replica...
parfor i = 1:len %Parfor for speed
    %Load trajectory file
    dcd = readdcd_all( fullfile(inp, sprintf(trajstr, i) ) );
    
    %Get backbone mesostrings of this trajectory
    [bb, phipsi] = getMeso_dcd(pdb, dcd);
    
    %Load mdout data
    mdo = loadmdout( fullfile( inp, sprintf(mdoutstr, i) ) );
    
    %Pick the mdout frames that match the traj frames
    mdo = mdo(2:end); %Strip t=0
    ndiv = length(mdo) / length(dcd); %Traj output is like 500, 1000, 1500, ... mdout output is 0, 100, 200, ...
    mdo = mdo(ndiv:ndiv:end);
    
    %Assemble to struct. Use mdo as the base
    [mdo.rep] = deal(i);
%     [mdo.traj] = deal(traj{:}); %very costly to keep, skip
    [mdo.bb] = deal(bb{:});
    [mdo.phipsi] = deal(phipsi{:});
    nf = length(fieldnames(mdo));
    
    %Reorder fields
    mdo = orderfields(mdo, [nf-1:nf 1:nf-2]  );
    
    out{i} = mdo;
end

if nargout > 1
%Save the leap.in and remd.mdin texts
    meta.leap = readtxt( fullfile(inp, leapin) );
    meta.mdin = readtxt( fullfile(inp, mdin) );
end





