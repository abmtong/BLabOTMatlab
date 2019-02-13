function extractFCsHMMV2(aseed, cropstr)
%gathers FCs for HMM processing
%takes crop, splits by FC
%splits also to make traces strictly increasing


if nargin < 1
    aseed = [];
end
if nargin < 2
    cropstr = '';
end
if ~ischar(cropstr)
    if isdouble(cropstr)
        cropstr = num2str(cropstr);
    else
        error('cropstr must be a string')
    end
end
%
%Based off of @Iterate_GatherFCs
%Get files
[files, path] = uigetfile('C:\Data\phage*.mat','MultiSelect','on');
%Check to make sure files were selected
if ~path
    return
end
if ~iscell(files)
    files = {files};
end

%Select output path
outpath = uigetdir(path);
    figure('Position', [0 0 960 540])
    ax = gca;
for i = 1:length(files)
    file = files{i};
%     Load crop
    cropfp = sprintf('%s\\CropFiles%s\\%s.crop',path, cropstr, file(6:end-4));
    fid = fopen(cropfp);
    if fid == -1
        fprintf('Crop not found for %s\n', file)
        continue
    end
    ts = textscan(fid, '%f');
    fclose(fid);
    crop = ts{1};
    %load file
    load([path file],'stepdata')
    %find start/end crop indicies
    indsta = cellfun(@(x)find(x>crop(1),1),        stepdata.time,'UniformOutput',0);
    indend = cellfun(@(x)find(x<crop(2),1,'last'), stepdata.time,'UniformOutput',0);
    %exract con/tim/frc values
    con = cellfun(@(ce,st,en)ce(st:en),stepdata.contour, indsta, indend, 'UniformOutput',0);
    frc = cellfun(@(ce,st,en)ce(st:en),stepdata.force, indsta, indend, 'UniformOutput',0);
    tim = cellfun(@(ce,st,en)ce(st:en),stepdata.time, indsta, indend, 'UniformOutput',0);
    %grab extras, if they exist
    opts = [];
    if isfield(stepdata, 'cal')
        opts.cal = stepdata.cal;
    end
    %stepdata.opts will have WLC params, comment, etc.
    if isfield(stepdata, 'opts')
        opts.opts = stepdata.opts;
    end
    
    %Prompt for fcs being ok
    len = length(con);

    for ik = 1:len
        cla(ax);
        connew = [];
        frcnew = [];
        timnew = [];
        if isempty(con{ik})
            continue
        end
        plot(ax, con{ik})
        resp = questdlg('Select trace section?', 'Select trace section?', 'Yes', 'No', 'No');
        if strcmp(resp, 'Yes')
            ii = 1;
            while true
                [x, ~]=ginput(2);
                x=round(sort(x))';
                x = max(x, [1 1]);
                x = min(x, length(con{ik})*[1 1]);
                yl = ylim;
                line(x(1)*[1 1], yl)
                line(x(2)*[1 1], yl)
                connew{ii} = con{ik}(x(1):x(2));
                frcnew{ii} = frc{ik}(x(1):x(2));
                timnew{ii} = tim{ik}(x(1):x(2));
                ii = ii + 1;
                resp2 = questdlg('Continue selecting?', 'Continue selecting?', 'Yes', 'No', 'No');
                if strcmp(resp2, 'No')
                    break
                end
            end
        else
            connew = con(ik);
            frcnew = frc(ik);
            timnew = tim(ik);
        end
        con = [con connew];
        con{ik} = [];
        frc = [frc frcnew];
        frc{ik} = [];
        tim = [tim timnew];
        tim{ik} = [];
    end
    
    %save in output file
    for j = 1:length(con)
        if ~isempty(con{j})
            %name file ['pHMM' MMDDYYN## {extra stuff might be here} S##P##.mat]
            outname = sprintf('pHMM%sS%0.2f.mat', file(6:end-4), tim{j}(1));
            fcdata = [];
            fcdata.con = con{j};
            fcdata.frc = frc{j};
            fcdata.tim = tim{j};
            fcdata.opts = opts;
            fcdata.aseed = aseed;
            save([outpath filesep outname], 'fcdata')
        end
    end
end

end