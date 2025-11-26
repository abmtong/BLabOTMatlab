function gbr2fig(infp)
%Converts a RS-274D Gerber (i.e., old ver.) to a .fig (== vector)

% Using reference for RS-274D from https://www.eurocircuits.com/technical-guidelines/gerber-format/rs274d-standard-gerber-with-separate-aperture-tables/

%Basically, find X%dY%dD%d* lines
%These files draw the board along a contiguous path using three main commands:
%D01 ~ 'Draw to this location'
%D02 ~ 'Move to this location'
%D03 ~ 'Add pad here'

%Let's draw D01's as lines, D03's as 'o' markers, i.e. plot(~,'o')

%Other lines may be D10+*, which tells which line thickness to use, and ending with M%d*, stating eof

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


[~, f, e] = fileparts(infp);
figure('Name', [f e]);
hold on
axis equal

fid = fopen(infp);
curpos = [0 0]; %Current X,Y position
xyd = {'X%d' 'Y%d' 'D%d'};
while ~feof(fid)
    %Parse line
    ln = fgetl(fid);
    
    %Try to read as X%dY%dD%d* , though it is possible only one X or Y is there
    
    %Could write something elegant, eh maybe
    hasxyd = [any(ln == 'X') any(ln == 'Y') any(ln == 'D')];
    
    if any(hasxyd)
%         %Form textscan string
%         tsstr = [xyd{hasxyd} '*'];
%         
%         %Textscan
%         ts = textscan(ln, tsstr);
%         if isempty(ts{1})
%             warning('Line %s failed', ln)
%         end
%         
% %         fd = find(hasxyd);
%         
%         newxyd = [curpos 0];
%         newxyd(hasxyd) = [ts{:}];
%         newpos = newxyd(1:2);
        %Textscan is acting funny... I think D's can be exponent? like it interprets 13874D02 as 13874e02
        %Maybe do more manual regexp-style
        
        reg = regexp(ln, '[XYD*]');
        if length(reg) < 2
            fprintf('Skipping/failed line %s', ln)
            continue
        end
        
        newxyd = [curpos 0];
        for i = 1:length(reg)-1
            num = str2double( ln( reg(i)+1: reg(i+1)-1 ) );
            switch ln(reg(i))
                case 'X'
                    newxyd(1) = num;
                case 'Y'
                    newxyd(2) = num;
                case 'D'
                    newxyd(3) = num;
                otherwise
                    warning('Wrong XYD scanning for line: %s', ln)
            end
        end
        
        %Draw
        if newxyd(3) == 1
            %Draw from curpos to newpos
            plot([curpos(1) newxyd(1)], [curpos(2) newxyd(2)], 'k')
        elseif newxyd(3) == 3
            %Draw 'o' at curpos
            plot(newxyd(1), newxyd(2), 'ko')
        end
        
        %Update curpos
        curpos = newxyd(1:2);
    else
        fprintf('Skipping line %s', ln)
    end
    
end

fclose(fid);
    