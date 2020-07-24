function plotmet(insd)
%Plots a table with metadata from a phage trace

opts = insd.opts;

dat = [fieldnames(opts), struct2cell(opts)];
cls = cellfun(@class, struct2cell(opts), 'un', 0);
%Keep if numeric or logical or text
ki = strcmp(cls, 'logical') | strcmp(cls, 'double') | strcmp(cls, 'char');
dat = dat(ki,:);

%Create figure
fg = figure('Name', 'PlotMetadata', 'Visible', 'off', 'MenuBar', 'none', 'ToolBar', 'none');
tb = uitable(fg, 'Data', dat);
%Extend table to however long it needs
tbext = tb.Extent(3:4);
tb.Position = [ 0 0 tbext];
%And resize figure to match size
fg.Position(3:4) = tbext;
fg.Visible = 'on';