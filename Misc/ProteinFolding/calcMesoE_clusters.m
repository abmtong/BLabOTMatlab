function out = calcMesoE_clusters(inp)
%Calculate meso E using the clustering method from cpptraj

%Clustering by cpptraj, using the tutorial from https://amberhub.chpc.utah.edu/clustering-a-protein-trajectory/
% This creates a lot of files, just process them all

%Filename strings for loading
tempstr = '99_temperatures.dat';
pdbstr = 'rep.%s.c%d.pdb';
cnumstr = 'cnumvtime.%s.dat';
cpopstr = 'cpopvtime.%s.agr';
diststr = 'dist.%s.dat';
summstr = 'summary.%s.dat';

%Settings
ncluster = 10; %Number of clusters cpptraj is told to find

% d = dir(fullfile(inp, avgstr));

% avgs = [d.name];

%Get temperature list
fid = fopen(fullfile(inp, tempstr));
tempsstr = textscan(fid, '%s');
%Load as string for creating filenames. Loading as double and converting with num2str works, but probably 'faster' this way?
tempsstr = tempsstr{1};
temps = str2double(tempsstr);

nT = length(temps);
outraw = cell(1,nT);
for i = 1:nT
    tmp = [];
    tmp.T = temps(i);
    
    %Load cnum vs time
    fid = fopen(fullfile(inp, sprintf(cnumstr, tempsstr{i})));
    %Read data = frame vs time. Actually, since this REMD, this might not be useful? eh keep
    t = textscan(fid, '%f %f', 'CommentStyle', '#');
    t = [t{:}];
    tmp.cnvt = t(:,2); %Strip x-axis (frame)
    fclose(fid);
    
    %Load cdist vs time (cluster distribution per frame). Might be useful to test 'equilibration'
    % Oh is this like a time-average from 1 to t? not so useful?
    fid = fopen(fullfile(inp, sprintf(cpopstr, tempsstr{i})));
    %Read data
    t = textscan(fid, '%f %f', 'CommentStyle', '@');
    t = [t{:}];
    t = t(:,2); %Strip x-axis (frame)
    t = reshape(t, [], ncluster); %Reshape to per-cluster values
    tmp.cdvt = t;
    fclose(fid);
    
    %Load end-to-end distance v time.
    fid = fopen(fullfile(inp, sprintf(diststr, tempsstr{i})));
    %Read data
    t = textscan(fid, '%f %f', 'CommentStyle', '#');
    t = [t{:}];
    tmp.dist = t(:,2); %Strip x-axis (frame)
    fclose(fid);
    
    %Load summary of clustering
    fid = fopen(fullfile(inp, sprintf(summstr, tempsstr{i})));
    %Read data
    t = textscan(fid, '%f %f %f %f %f %f %f', 'CommentStyle', '#');
    tmp.summ = t; 
    fclose(fid);
    %Columns are Cluster#/N/%/AvgDistance/STDDistance/Centroid/AverageCDist
    
    %Load files that separate by cluster
    meso = cell(1,ncluster);
    ang = cell(1, ncluster);
    for j = 1:ncluster
        %Load pdb and calculate their mesostate
%         pp = pdbread( fullfile( inp, sprintf(pdbstr, temps(i), j-1) ) ); %Clusters are 0-indexed
        [meso{j}, ang{j}] = getMeso( fullfile( inp, sprintf(pdbstr, tempsstr{i}, j-1) ) );
        
    end
    tmp.meso = meso;
    tmp.phipsi = ang;
    
%     %Assemble output struct
%     tmp = struct();
    %Save
    outraw{i} = tmp;
end

out = [outraw{:}];
