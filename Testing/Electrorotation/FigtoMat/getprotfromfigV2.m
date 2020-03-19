function out = getprotfromfigV2(inpf)
%From a ElRo data figure, extract the angular hist + protocol
%Output: Nx6 cell, where the columns are:
% { 1: Filename, 2: Angular Hist from arctan(x/y) coordinates, 3: Angular Hist from rotation angle
% 4:  Protocol that LabVIEW calculated ( [angle, velocity] ). This is what is used in the experiment.
% 5:  Protocol that Matlab claculated - I can't seem to make the two equate, I will work on that more in the future.
% 6:  Raw data that Matlab calculated - individual velocities calculated from a singe dwell. These are averaged to get the Matlab protocol. }

%I'm extracting everything that I think might be useful; feel free to use whatever you think you might need.
%The angular hist from the rotation angle is probably better to use.
%Contact me / modify if you think you might need something else from the data figures.

%Choose files
if nargin < 1
    [f, p] = uigetfile('*.fig', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        out = cellfun(@(x) getprotfromfigV2([p x]), f, 'Un', 0);
        %Reshape to one array
        out = reshape([out{:}]', 6, [])';
        return
    end
end

out = cell(1,5);

%Get filename
[~, file] = fileparts(inpf);

%Load figure
fg = openfig(inpf);
fg.Visible = 'off';
axs = fg.Children;

%Get figure titles
tits = cellfun(@(x) x.String, {axs.Title}, 'Un', 0);

%Find axis for Angular Histogram, if it exists
indah = find(strcmp(tits, 'Angular Histogram'));
if ~isempty(indah)
    ax = axs(indah);
    %Get line objects, extract [x,y] data
    lns = ax.Children;
    tmp = arrayfun(@(x) [x.XData' x.YData'], lns, 'Un', 0);
    %Sanity check, write at most 2 rows
    n = min(2,numel(tmp));
    out(1:n) = tmp(1:n);
end

%Find axis for Protocol, if it exists
indpr = find(strncmp(tits, 'Protocol', 8)); %The title will be 'Protocol (Hy)' or 'Protocol (Syn)' depending on source
if ~isempty(indpr)
    ax = axs(indpr);
    %Get objects, extract [x,y] data
    objs = ax.Children;
    %Should be Line, ErrorBar, Scatter, Scatter = ProtLV, ProtML, MLRaw, MLRawOp
    tmp = arrayfun(@(x) [x.XData' x.YData'], objs, 'Un', 0);
    if length(tmp) == 4
        tmp{3} = [tmp{3}; tmp{4}]; %Combine together the separated raw velocity values
        out(3:5) = tmp(1:3);
    else %Something weird
        [~, f] = fileparts(inpf);
        warning('I dont know how to read this file: %s, oops', f)
    end
end

%Close figure
delete(fg);

%Append filename
out = [{file} out];
