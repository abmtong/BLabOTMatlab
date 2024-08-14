function out = ezDroAP_batch(inst, infp)
%Wrapper for ezDroAP and ezDroMoviePos
% Also needs the movie's last frame, so pass the struct from ezDro_batch

%Input: path to a file in the folder with Mid_Mid_RAW_ch01.tif and Surf_Surf_RAW_ch01.tif


if nargin < 2
    [f p] = uigetfile('*.tif');
    if ~p
        return
    end
    infp = fullfile(p,f);
end

[p f e] = fileparts(infp);

%Get final frame of ch2, which is just inst(end)
movimg = inst(end).imgraw;

%Filepath for embryo midsection file
fpmid = fullfile(p, 'Mid_Mid_RAW_ch01.tif');
imgmid = imread(fpmid);

%Filepath for embryo surface file
fpsurf = fullfile(p, 'Surf_Surf_RAW_ch01.tif');
imgsurf = imread(fpsurf);

%Do ezDroAP
ap = ezDroAP(imgmid, struct('verbose', 0));

%Do ezDroMoviePos
mp = ezDroMoviePos( movimg , imgsurf, struct('verbose', 0));

%Assemble output
out.apdv = ap;
out.movpos = mp;
out.embimg = max( imgmid, imgsurf );