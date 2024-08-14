function out = calcsnr()

tsep = 600:10:1000;

trapk = 0.1;

wlc = {35 900}; %DNA XWLC params . Shaw paper is ~35nm/900pN/980nm
% wlc = {400 900}; %Origami

% wlc = {2000 inf}; %Origami theoretical



len = length(tsep);


ff = zeros(1,len);
ss1 = zeros(1,len);
ss2 = zeros(1,len);
nn = zeros(1,len);
for i = 1:len
    %Get F from simhop
    tmp = simhop(tsep(i), wlc, trapk, 3);
    ff(i) = mean(tmp.frc);
    ss1(i) = abs(diff(tmp.ext));
    
    ss2(i) = XWLCslope( mean(tmp.frc), wlc{:});
    
    
    %Get N from simnoi
    nn(i) = simnoi(ff(i));
    
    %Looking at two Ross data at different trapk's, 
% it looks like the ext noise is constant, the force noise goes with k. So let's compare nm noise and nm signal
    
end


if nargout
    out = [ff', ss1'./nn'];
else
    %And plot SNR
    figure,
    plot(ff, ss1 / max(ss1) )
    hold on, plot(ff, ss2 / max(ss2) )
    
    plot(ff, nn / max(nn) )
    
    yyaxis right
    plot(ff, ss1./nn)
    
    legend({'Simhop S' 'XWLCslope S' 'Noise' 'SNR'})
    
end