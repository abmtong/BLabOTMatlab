function out = loadREMD_batch(inp)
%Load all REMDs in this folder

if nargin < 1
    inp = uigetdir();
end


d = dir(inp);

d = d(3:end); %Strip . and ..
d = d( [d.isdir] ); %Get folders
f = {d.name};

%Pick folders
f = inputdlg_choosestr(f);
if isempty(f)
    return
end

leapin = '99_leap.in'; %LEaP file
mdin = '99_remd.mdin'; %REMD mdin

len = length(f);
out = cell(1,len);

for i = 1:len
    thisp = fullfile(inp, f{i});
    
    %Try loadREMD, will work if it's valid data
%     try
%         [traj, meta] = loadREMD( thisp );
%     catch
%         fprintf('Folder %s failed\n', f{i})
%         continue
%     end
    
    %Save things to struct
    tmp = [];
    tmp.nam = f{i};
    
    tmp.leap = readtxt( fullfile(thisp, leapin));
    tmp.mdin = readtxt( fullfile(thisp, mdin) );
    tmp.traj = tmp;
    
    
    %Do analysis
%     [me, memeta] = calcMesoE(tmp);
%     tmp.mdist = calcMesoDist(me);
    tmp.mcluster = calcMesoE_clusters( thisp );
    
    %Save
%     out{i} = struct('nam', f{i}, 'traj', {tmp}, 'meso', me, 'mesometa', memeta, 'mdist', md, 'leap', meta.leap, 'mdin', meta.mdin);
    out{i} = tmp;
end

out = [out{:}];