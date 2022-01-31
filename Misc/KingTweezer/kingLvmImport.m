function out = kingLvmImport(infp)

if nargin < 1
    [f, p]  = uigetfile('*.lvm');
    infp = [p f];
end

raw = lvm_import(infp);

rawdat = raw.Segment1.data; %column matrix of [time A B C D] (QPD quadrant volatges)

x = rawdat(:,2) + rawdat(:,3) - rawdat(:,4) - rawdat(:,5);
y = rawdat(:,2) + rawdat(:,4) - rawdat(:,3) - rawdat(:,5);

frc = sqrt( x.^2 + y.^2 );

out.fx = x;
out.fy = y;
out.frc = frc;
out.t = rawdat(:,1);