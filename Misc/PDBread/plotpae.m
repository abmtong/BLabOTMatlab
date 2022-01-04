function plotpae(inst)

fg = figure('Color', [1 1 1]);
ax=gca;

cm = inst.predicted_aligned_error; %From an AlphaFold output (probably not general)

surface( ones(size(cm)), cm, 'EdgeColor', 'none' );

%Set up axis
axis tight
axis equal
ax.CameraUpVector = [-1 0 0]; %This places the horiz axis at the top (bad) but we just want the internals so whatever
ax.CLim = [0 30]; %Match the color limits. Seems about right for this type of data, anyway


colormap(rwbcmap(128, 1)) %Made my own red-white-blue colormap, simple linear brightness decrease
colorbar

%Want output graph to be 300px square
fg.Position = [0 0 600 600];
ax.Position = [.25 .25 .5 .5];