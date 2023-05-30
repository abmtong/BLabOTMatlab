function out = prepDcPwebV2p2_helper(infp, nlen)
%Reads the wig, reshapes


%Read text file
fid = fopen(infp);
%Read first line, which is a header
fgetl(fid);
%Read next lines as '%d %f' = position, cyc-ity
lns = textscan(fid, '%d %f');
fclose(fid);
%pos = lns{1};
scr = lns{2};


%Pad start and end and reshape
out = reshape([ nan(1,24) scr(:)' nan(1,25)], nlen, []);
