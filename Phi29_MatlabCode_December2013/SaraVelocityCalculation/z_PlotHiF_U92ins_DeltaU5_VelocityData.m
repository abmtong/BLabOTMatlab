load('U92ins_DeltaU5_HiF_VelocityData.mat');

%plot 3000-4000 tether length (17000-18000 filling)
figure;
hold on;
vel = U92.VelocityMean(2:8,3);
err = U92.VelocityErr(2:8,3);
force = U92.ForceRangeFmin(2:8);
errorbar(force-.1,vel,err,'.k');
vel = DU5.VelocityMean(1:10,3);
err = DU5.VelocityErr(1:10,3);
force = DU5.ForceRangeFmin(1:10);
errorbar(force+0.1,vel,err,'.b');
legend('U92Ins','DeltaU5');
xlabel('Force (pN)');
ylabel('Velocity (bp/s)');
title('Capsid Filling 17-18kb');
axis([0 30 0 60]); set(gca,'Box','on');

%% plot 4000-5000 tether length (16000-17000 filling)
figure;
hold on;
vel = U92.VelocityMean(1:10,4);
err = U92.VelocityErr(1:10,4);
force = U92.ForceRangeFmin(1:10);
errorbar(force-.1,vel,err,'.k');
vel = DU5.VelocityMean(1:10,4);
err = DU5.VelocityErr(1:10,4);
force = DU5.ForceRangeFmin(1:10);
errorbar(force+0.1,vel,err,'.b');
legend('U92Ins','DeltaU5');
xlabel('Force (pN)');
ylabel('Velocity (bp/s)');
title('Capsid Filling 16-17kb');
axis([0 30 0 60]); set(gca,'Box','on');

%% plot 5000-6000 tether length (15000-16000 filling)
figure;
hold on;
vel = U92.VelocityMean(1:9,5);
err = U92.VelocityErr(1:9,5);
force = U92.ForceRangeFmin(1:9);
errorbar(force-.1,vel,err,'.k');
vel = DU5.VelocityMean(1:10,5);
err = DU5.VelocityErr(1:10,5);
force = DU5.ForceRangeFmin(1:10);
errorbar(force+0.1,vel,err,'.b');
legend('U92Ins','DeltaU5');
xlabel('Force (pN)');
ylabel('Velocity (bp/s)');
title('Capsid Filling 15-16kb');
axis([0 30 0 60]); set(gca,'Box','on');

%% Plot RUpture Data
%U5 data
close all;
U5.Force   = [25 19.2 22.8 23.6 20.5 19.3 23.8 24.9 26.9 28.9 24.5];
U5.Filling = (21000 - [2920 5563 2805 2245 1674 2781 3431 5351 4423 3358 2925])/19300*100;
figure; hold on;
U92.Force = [20.6 21.9 17.5 24.0 22.2];
U92.Filling = (21000 - [5419 3523 4472 2960 3343])/19300*100;
plot(U92.Force,U92.Filling,'+b');
plot( U5.Force, U5.Filling,'ok');
axis([15 30 0 105]); set(gca,'Box','on');
legend('U92Ins','DeltaU5');

%% Filling Data
close all;
U5Fill = (21000-[3024 3099 2979 2294 2032 4065 2386 2096 3510 1666 2282 2370 2383 1758 1830 2408 2590 2253 3109])/19300*100;
U92Fill = (21000-[2445 1495 4195 1788 1683 2420 2206 1970 3709 2177 2684 2307 1889 2331 1452 2219 3034 2264 3416])/19300*100;
figure; hold on;
plot(U92Fill,5*ones(size(U92Fill)),'.b');
plot(U5Fill,6*ones(size(U92Fill)),'.k');
axis([86 102 0 10]);
xlabel('Capsid Filling Reached (%)');
set(gca,'YTick',[]);
set(gca,'Box','on');
legend('U92Ins','DeltaU5');