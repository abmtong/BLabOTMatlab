function pdata = CK_FindRampBoundariesMini(ClearExisting)

%%
if nargin<1
    ClearExisting = 0;
end

[dfile,dpath] = uigetfile('/Users/Lisa/Desktop/TweezersData/*.mat', 'MultiSelect','on');
if ~iscell(dfile)
    dfile={dfile};
end


%% Get file name, load file, check for existing annotation
for nFile = 1:numel(dfile)
    disp(['Processing ' dfile{nFile}]);
    load([dpath dfile{nFile}]);
    %x = pdata.A_distY; %original code
    x = -pdata.Y_force; %modified by LA
    
    if isfield(pdata,'RampBoundaries')
        B = pdata.RampBoundaries;
    else
        B = [];
    end

    if ClearExisting == 1
        B = [];
    end

    cont = 1;
    while cont==1
        %% define boundaries based on user input

        % initialize figure
        figure('Units','normalized','Position',[0.0 0.3 1.0 0.7]);


        % plot data with exisiting annotations
        plot(x,'-b')
        hold on;
        if ~isempty(B)
            for j = 1:size(B,1)
                idx = B(j,1):B(j,2);
                plot(idx,x(B(j,1):B(j,2)),'.','MarkerEdgeColor', rand(3,1));
            end
        end
        zoom on;
        disp('    adjust zoom, then press any key to make selections...')
        pause;


        % get start position
        disp('    select beginning of segment... (1 click)');
        [a,junk] = ginput(1);
        s = round(a);





        % refine positions
        % beginning
        fS = 1000;
        wnd = 2*fS;

        idx1 = s-wnd;
        if idx1<1
            idx1 = 1;
        end

        idx2 = s+wnd;
        if idx2>numel(x)
            idx2 = numel(x);
        end

        % determine whether click is in a minimum or a maximum
        if x(idx1)<x(s) || x(idx2)<x(s)
            % maximum
            [junk,s] = max(x(idx1:idx2));
        else
            % minimum
            [junk,s] = min(x(idx1:idx2));
        end
        s = s + idx1;

        plot(s,x(s),'.g','MarkerSize',20)

        % get end position

        disp('    select end of segment... (1 click)');
        [a,junk] = ginput(1);
        e = round(a);





        % end
        idx1 = e-wnd;
        if idx1<1
            idx1 = 1;
        end

        idx2 = e+wnd;
        if idx2>numel(x)
            idx2 = numel(x);
        end

        % determine whether click is in a minimum or a maximum
        if x(idx1)<x(e) || x(idx2)<x(e)
            % maximum
            [junk,e] = max(x(idx1:idx2));
        else
            % minimum
            [junk,e] = min(x(idx1:idx2));
        end
        e = e + idx1;


        plot(e,x(e),'.b','MarkerSize',20)
        plot((s:e)',x(s:e),'.r','MarkerSize',5)
        pause(0.2)    

        disp('Press e to exit and save,')
        disp('      q to quit without saving,')
        disp('      c to clear last selection')
        disp('      any key to add another segment. ')
        waitforbuttonpress;
        a = get(gcf,'CurrentCharacter');
        if a == 'e'
            cont = 0;
            B = [B;s,e];
            pdata.RampBoundaries = B;
            disp(['    Saving ' dfile{nFile}]);
            pause(0.1)
            save([dpath dfile{nFile}],'pdata');
        elseif a == 'q'
            cont = 0;
        elseif a == 'c'
        else
            B = [B;s,e];
            pdata.RampBoundaries = B;
        end
        close gcf;
    end    
end    

disp('Done.')
%close all;



