function outFile = AlexCreateAnalysisFile()
%Takes a much simpler text file able to be used by the Phi29 MATLAB tools.
%Input file:
%033117 {date of experiments in MMDDYY format}
%01  03   02 {data offset calibration}
%[continue one line per trace, leading 0s not required on data files]
%becomes
%033117N01 offset033117N03 cal03117N02
%Outputs the filepath of the created text files

defaultPath = 'C:\Data\Analysis\*.txt'; %Where you store analysis files, just saves on navigation

%This will automatically SetAnalysisPath and SetRawDataPath if you want
%For quickest use, setup your data/analysis files like this:
%.\Analysis\MMDDYY\[analysis.txt]
%.\RawData\MMDDYY\mmddyyN##.dat
%If they're not like that, the program will prompt you.

%This will also do Phage/ForceExtension analysis

%Pick your file
[file, path] = uigetfile(defaultPath,'Select your text file');
if ~path %No file selected
    return
end
filepath=[path file];

%Parse the file
fid = fopen(filepath);
scn = textscan(fid, '%s %s %s');
fclose(fid);
date = scn{1}{1};
%If the file is already in MMDDYN## format, skip making the file
if isempty(scn{2}{1}) && length(scn{1}{1}) > 6
    outFile = filepath;
    %Still need the date in MMDDYY format
    ind = regexp(date,'N');
    date = date(1:ind-1);
    fprintf('Input detected as MATLABanalysis file\n')
else %Create MATLABanalysis file
    %Extract the columns
    dat = scn{1}(2:end);
    off = scn{2}(2:end);
    cal = scn{3}(2:end);
    %Format the strings
    %Format to MMDDYYN##
    dat = strcat(date,'N',dat);
    %Format to offsetMMDDYYN##
    off = strcat('offset',date,'N',off);
    %Format to calMMDDYYN##
    cal = strcat('cal',date,'N',cal);
    %Create the converted file with the name '[date]MATLABanalysis.txt'
    outFile = [fileparts(filepath) filesep date 'MATLABanalysis.txt'];
    fid2 = fopen(outFile,'w');
    %Write the values to the file
    for i=1:length(dat)
        fprintf(fid2,'%s\t%s\t%s\r\n',dat{i},off{i},cal{i});
    end
    fclose(fid2);
    fprintf('MATLABanalysis file saved to %s\n',outFile)
end

%Prompt the user to set paths automatically.
%'Yes' assumes the input text file is in the analysis folder, and the raw data is in ..\..\RawData\MMDDYY\.
%If they're in different places, you can set them with the gui file picker
response = questdlg('Would you like to set paths?','Run SetAnalysisPath?','Yes','Prompt me','No','No');
switch response
    case 'Yes'
        SetAnalysisPath(path);
        fprintf('Analysis path: %s\n', path)
        rawpath = [path '..' filesep '..' filesep 'RawData' filesep date filesep];
        if exist (rawpath,'dir')
            SetRawDataPath(rawpath);
            disp(['Raw Data path: ' rawpath])
        else
            disp('Raw data path not found at ..\..\RawData\MMDDYY, prompting:')
            SetRawDataPath
        end
    case 'Prompt me'
        disp('Analysis path:')
        SetAnalysisPath
        disp('Raw Data path:')
        SetRawDataPath      
    case 'No'
        disp('Output file saved to:');
end

%Reminder that the bead radius in GheCalibrate needs to be set manually. Eventually pass this as a param.
response4 = questdlg('Do you need to set the bead radius for calibration?','Set Bead Radius','Yes','No','No');
switch response4
    case 'Yes'
        addpath('.\BrownianCalibration\')
        open GheCalibrate_Alex
        fprintf('Press a key in the command window to continue. R2016a has an issue and sometimes won''t continue (Quit with Ctrl+C)\n')
        pause
end

%Prompt the user to create offset/calibration files.
%It uses the MATLABanalysis.txt file as the source of the filenames, and use the paths specified earlier
response2 = questdlg('Would you like to create offset/calilbration files?','Create offset/cal?','Yes','No','YesOffV2','No');
switch response2
    case 'Yes'
        addpath('.\BrownianCalibration\')
        GheCalibrate_Alex(outFile);
        addpath('.\Offset\')
        MakeOffsetFiles_Batch_Alex(outFile);
    case 'YesOffV2'
        addpath('.\BrownianCalibration\')
        GheCalibrate_Alex(outFile);
        addpath('C:\Users\Alexander Tong\Box Sync\Year 2 Semester 2\Res\MATLAB\Testing\OffsetV2\')
        BatchOffset(outFile);
end

%Prompt the user to create data files.
%It uses the %MATLABanalysis.txt file as the source of the filenames, and use the paths specified earlier
response3 = questdlg('Would you like to create Phage/ForceExt files?','Create Phage/ForceExt?','Phage','ForceExt','No','No');
switch response3
    case 'Phage'
        Alex_ParsePhageTraces_Batch(outFile);
    case 'ForceExt'
        addpath('.\ForceExtension\')
        Alex_ForceExt_ParseTrace_Batch(outFile);
end
