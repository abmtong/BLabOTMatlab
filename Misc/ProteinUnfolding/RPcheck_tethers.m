function out = RPcheck_tethers(inst)
%Separate by file and post some info per file

Fs=25e3;

nams = {inst.file};
[uu, ia, ic] = unique(nams);

nfil = length(uu);
rawdat = cell(1,nfil);

%Get some bulk stats
xlen = arrayfun(@(x) length(x.ext), inst);
tp1 = arrayfun(@(x) x.tpos(1), inst);
tp2 = arrayfun(@(x) x.tpos( x.retind ), inst);
tp3 = arrayfun(@(x) x.tpos(end), inst);
ri = [inst.retind];
ps = (tp2-tp1)./(ri)*Fs; %Pull speed, nm/s
rs = (tp2-tp3)./(xlen-ri)*Fs; %Retract speed, nm/s

ss = get(0, 'ScreenSize');
figure( 'Name', 'RPcheck Tethers', 'Position', [ss(3:4)/8 ss(3:4)*0.75] )
ax(1) = subplot2([2,2],1, .1);
hold on
xlabel('DNA PL (nm)')
ylabel('DNA SM (pN)');
ax(2) = subplot2([2,2],2, .1);
hold on
xlabel('P PL (nm)')
ylabel('P CL (nm)');
ax(3) = subplot2([2,2],3, .1);
hold on
xlabel('N Pulls')
ylabel('Pull Duration (pts)');
ax(4) = subplot2([2,2],4, .1);
hold on
xlabel('Pull speed (nm/s@25kHz)')
ylabel('Retract speed (nm/s@25kHz)');

for i = 1:nfil;
    tmp = inst(ia(i));
    
    %Grab stats: DNA SM + PL, P PL + CL, N Rips, N Pts per pull (speed-adjacent)
    t = [tmp.xwlcft([1 2 6 7]) sum(ic == i) mean(xlen(ic==i))  mean(ps(ic == i)), mean(rs(ic == i))  ];
    
    rawdat{i} = t;
    plot(ax(1), t(1), t(2), 'o')
    plot(ax(2), t(3), t(4), 'o')
    plot(ax(3), t(5), t(6), 'o')
%     plot(ax(4), t(7), t(8), 'o')
    
    %Plot pull/retract speed
    
%     plot(ax(4), (ps(ic == i)), (rs(ic == i)), 'o');
    plot(ax(4), t(7), t(8), 'o');
    
end

legend(ax(1), uu, 'FontSize', 8)

%Reshape output
out = reshape([rawdat{:}], [], nfil)';
% 
% %And plot
% figure Name RPcheckTethers
% 
% subplot(2,2,1)
% plot(out(:,1),out(:,2), 'o')
% xlabel('DNA PL (nm)')
% ylabel('DNA SM (pN)');
% 
% subplot(2,2,2)
% plot(out(:,3),out(:,4), 'o')
% xlabel('P PL (nm)')
% ylabel('P CL (nm)');
% 
% subplot(2,2,3)
% plot(out(:,5),out(:,6), 'o')
% xlabel('N Pulls')
% ylabel('Pull Duration (pts)');
% 
% subplot(2,2,4)
% plot(out(:,7),out(:,8), 'o')
% xlabel('N Pulls')
% ylabel('Pull Duration (pts)');
% 
% %Plot... 2d DNA SM, PL
%     
%     %Plot... 2d DNA CL, P CL
%     
%     %Plot... N rips, avg speed?