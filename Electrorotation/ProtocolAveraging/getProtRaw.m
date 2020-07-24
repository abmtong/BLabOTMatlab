function out = getProtRaw(intext)
%Saves raw protocol acorrs , input is the column from .xls file (filename, filenums)

rootpre = 'C:\Users\Alexander Tong\Box Sync';
rootnew = 'D:\Box Sync';

%process input
%Expecting filepath ('C:\...') then numbers

out = cell(length(intext),5);
i=1;
for txt = intext;
    str = txt{1};
    num = str2double(str);
    %Check what text is
    if isnan(num)
        %ignore 'prot'
        if strcmp(str, 'prot')
            continue
        end
        path = strrep(str, rootpre, rootnew);
        nums = [];
    else %number
        if num == -1
            continue
        end
        %Skip ones we've already loaded
        if any(nums == num)
            continue
        end
        fp = strrep(path, 'A001.mat', sprintf('A%03d.mat', num));
        [~, name] = fileparts(fp);
        try
            dat = load(fp, 'eldata');
        catch
            try
            dat = load(strrep(path, 'A001.mat', sprintf('B%03d.mat', num)), 'eldata');
            catch
                warning('%s file not found', name)
            end
        end
        dat = dat.eldata;
        try
            [~,~,acr, ki1, ki2, tp] = getProtocol(dat, struct('verbose', 0));
        catch
            warning('%s failed', name)
            continue
        end
        out(i,:) = {name tp acr ki1 ki2};
        i=i+1;
        nums = [nums num]; %#ok<AGROW>
    end
end