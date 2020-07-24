function [W, Wraw, Frc] = sumWork(inx, inp)
%Calculates the work given x (bead position) and p (trap position)
% All values are /k

%The force given by potential U=-kcos(2th) is F = 2ksin(2th).
% F is then 4 times as much?

%W = F-bar * diff(theta)
dth = (diff(inx));
Frc = mod((inx - inp) + pi/2, pi) - pi/2; %Make within [-pi/2, pi/2]
fbar = (Frc(1:end-1) + Frc(2:end))/2; %Average force
Wraw = dth .* fbar;
W = sum(Wraw);