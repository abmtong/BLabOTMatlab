function plotnrgmats(me, sd)


rownams = {'Nai Syn' 'Nai Hyd' 'Opt Syn' 'Opt Hyd' 'Opt Syn op' 'Opt Hyd op'};
x = [1 5 10]; %hz

figure name PlotEnergies
fg = gcf;
fg.Color = [1 1 1];
hold on

%Make hydrolyses red, syntheses blue; 1/3rd sat. for naive, full sat. for blue, 2/3rd for op
b3 = [41,128,185]/255;
b3h = rgb2hsv(b3);
% r3 = [192,57,43]/255; %dark red
r3 = [231,76,60]/255; %light red
r3h = rgb2hsv(b3);

% b2 = hsv2rgb(b3h.*[1 1 1.1]);
% b1 = hsv2rgb(b3h.*[1 1 1.3]);
% r2 = hsv2rgb(r3h.*[1 1 1.1]);
% r1 = hsv2rgb(r3h.*[1 1 1.3]);

b1 = (b3 + [2 2 2]) / 3;
b2 = (b3 + [1 1 1]) / 3;
r1 = (r3 + [2 2 2]) / 3;
r2 = (r3 + [1 1 1]) / 3;
col = {b1 r1 b3 r3 b2 r2};

for i = 1:6
    errorbar(x, me(:,i), sd(:,i), 'Color', col{i}, 'LineWidth',2)
end

legend(rownams)
xlabel('Rotation Rate (Hz)')
ylabel('Work on bead/Revolution (pNnm)')
axis tight
