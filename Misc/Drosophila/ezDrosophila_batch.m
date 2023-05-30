function out = ezDrosophila_batch(infp)


frange = [];% 10:10:200; %Let us only process certain frames. Leave empty to do all frames

%Files are arranged in this structure:
%{
RawDynamicsData\<DATE>\<NAME>\<pre>_<time>_<zslice>_RAW_<ch>.tif
 This is the raw data
ProcessedData\<DATE>-<NAME>_\dogs\<dogtype><DATE>-<NAME>_<Frame>_<ch>
 This is 'dogs' which are the spot detection results
 
PreProcessedData\<DATE>-<NAME>\<DATE>-<Name>_<03d>_<ch>
 This is the raw data processed into something more handleable, combined across Z slices
and DynamicsResults, which I am not going to use

<DATE> is YYYY-MM-DD
<ch> is ch%02d
<frame> is %03d
<pre> I'm guessing is the microscope name, E7_Series006
<time> is the frame number , t%02d ?
<zslice> is the z slice, z%02d
<dogtype> is 'dogStack_' or 'prob' depending on analysis type (traditional vs ML)
name = P2P-MS2v5-LacZ-PP7v4-E7

file = E7_Series006_t00_z00_RAW_ch00.tif
dogStack_2022-12-30-P2P-MS2v5-LacZ-PP7v4-E7_001_ch01
%}

%So choose one of the PreProcessedData files and nav from there

if nargin < 1
    [f, p] = uigetfile('*.tif');
    infp = fullfile(p,f);
end

%Grab names from this file
[p f e] = fileparts(infp);
%Strip the _%03d_ch%02d from the end
prename = f(1:end-9);
%Decompose this string for 'YYYY-MM-DD' at the front
% predate = f(1:10);
% prename = f(12:end-9);

%Grab file range from this folder
d = dir(p);
nams = {d.name};
nams = nams( ~[d.isdir] );
%Extract the frame#s of these files
frnos = cellfun( @(x) str2double( x( end-11:end-9 )), nams );
%This wont always work, but should be 'good enough'. Assumes a lot...
%And get the uniques
frnos = unique(frnos); %Also sorts
%Ignore nans
frnos = frnos( ~isnan(frnos) );

%Apply frame cropping
if ~isempty(frange)
    frnos = intersect(frnos, frange);
end


%Go up two folders to get the highest folder (where PreProcessedData and ProcessedData folders are)
pbase = fileparts( (fileparts(p)));
%And go through our paired files

len = length(frnos);
outch1 = cell(1,len);
outch2 = cell(1,len);
parfor i = 1:len %Parfor for speed
    %Create img paths
    imgfp1 = fullfile(pbase, 'PreProcessedData', prename, sprintf('%s_%03d_ch%02d.tif', prename, frnos(i), 1 ));
    imgfp2 = fullfile(pbase, 'PreProcessedData', prename, sprintf('%s_%03d_ch%02d.tif', prename, frnos(i), 2 ));
    %Create mask paths
    mskfp1 = fullfile(pbase, 'ProcessedData', [prename '_'], 'dogs', sprintf('prob%s_%03d_ch%02d.tif', prename, frnos(i), 1 ));
    mskfp2 = fullfile(pbase, 'ProcessedData', [prename '_'], 'dogs', sprintf('prob%s_%03d_ch%02d.tif', prename, frnos(i), 2 ));
    
    %Run ezDrosophila
    tmp1 = ezDrosophila(imgfp1, mskfp1);
    tmp2 = ezDrosophila(imgfp2, mskfp2);
    drawnow
    
    %Add some metadata
    tmp1.frame = frnos(i);
    tmp2.frame = frnos(i);
    tmp1.ch = 1;
    tmp2.ch = 2;
    
    outch1{i} = tmp1;
    outch2{i} = tmp2;
end

%Concatenate structs
outch1 = [outch1{:}];
outch2 = [outch2{:}];
out = [outch1 outch2];


%{
File path:
C:\Users\Abmtong\Desktop\Work\Drosophila...
\PreProcessedData\2022-12-30-P2P-MS2v5-LacZ-PP7v4-E7\2022-12-30-P2P-MS2v5-LacZ-PP7v4-E7_002_ch01.tif
dog path:
C:\Users\Abmtong\Desktop\Work\Drosophila...
\ProcessedData\2022-12-30-P2P-MS2v5-LacZ-PP7v4-E7_\dogs\prob2022-12-30-P2P-MS2v5-LacZ-PP7v4-E7_118_ch01.tif
%}





