function drl2fig(infp)
%Converts a drill file ('Excellion format'?) to a Figure

if nargin < 1
    [f, p] = uigetfile('*.*', 'Mu', 'on');
    if ~p
        return
    end
    if iscell(f)
        cellfun(@(x) gbr2fig( fullfile(p, x) ), f );
        return
    end
    
    infp = fullfile(p,f);
end

%Lines are either:
%T%dF%dS%d : Set drill type?
%X%dY%d : Drill location?

%So read drill types, then plot a Text with the T# at that spot?

[~, f, e] = fileparts(infp);
figure('Name', [f e]);
hold on
axis equal

fid = fopen(infp);
curdrl = ''; %Current drill 'name'
% tfs = 'T%dF%dS%d';
% xyd = {'X%dY%d'};
while ~feof(fid)
    %Parse line
    ln = fgetl(fid);
    
    if isempty(ln)
        continue
    end
        
    
    %Identify line by first letter, ig
    if ln(1) == 'T'
        reg = regexp(ln, '[TF]');
        curdrl = ln(reg(1)+1:reg(2)-1);
    elseif ln(1) == 'X'
        reg = regexp(ln, '[XY]');
        %Pad to 6 numbers, since that seems like how this works
        xs = ln(reg(1)+1: reg(2)-1);
        ys = ln(reg(2)+1:end);
        xs = [xs repmat('0', 1, 6-length(xs)) ];
        ys = [ys repmat('0', 1, 6-length(ys)) ];
        
        xx = str2double( xs );
        yy = str2double( ys );
        
       
        
        text(xx, yy, curdrl)
    else
        fprintf('Skipping line %s\n', ln)
    end
    
end

fclose(fid);


%And do limits
ax = gca;
tx = ax.Children;
pos = reshape([tx.Position], 3, [])';
xlim( [min(pos(:,1)), max(pos(:,1))] );
ylim( [min(pos(:,2)), max(pos(:,2))] );



    