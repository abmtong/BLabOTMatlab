function CropDataByHand()
% Open a phage trace and let the user crop the trace. This gives us Tstart
% and Tstop - the time limits that define the useful portion of the data.
% This start/stop time will be saved in a file named ***.crop. 
% The start time is written in the first line
% The stop time is wrtitten in the second line
%
% USE: HIP_CropDataByHand()
%
% Gheorghe Chistol, June 21 2010
%% Load the phages
AddMainCodePath; %add the old code folder to the path
Phages=LoadPhage(); %the location of the file is stored in analysisPath
clear stepdata;

%% Select the portion of the data that you want analyzed
for i=1:length(Phages)
    PlotPhagesDecimate(Phages(i),20);
    F=gcf; %F is the handle of the current figure
    set(gcf,'Units','normalized','Position',[0.0081    0.0625    0.9839    0.8333]);
    xlabel('Time (sec)');
    ylabel('Tether Length (bp)');
    title(['File: ' Phages(i).file '; Draw a crop box:']);
    set(gca,'Ylim',[-1000 21000]); %set the vertical axis limit
    set(F,'Pointer','fullcrosshair');
    
    decision=1;
    while decision==1
        k = waitforbuttonpress;
        point1 = get(gca,'CurrentPoint');    % first point detected
        finalRect = rbbox;                   % return figure units
        point2 = get(gca,'CurrentPoint');    % second button detected
        point1 = point1(1,1); %extract the time coordinate of the first pt              
        point2 = point2(1,1); %extract the time coordinate of the second pt
        start = min(point1,point2); %start analyzing at this time
        stop = max(point1,point2); %stop analyzing at this time
        set(gca,'XLim',[start stop]);
        set(gca,'YLimMode','auto');

        answer = questdlg('Accept this crop?','Accept Crop','Accept Crop','Crop More','Crop More');
        switch answer
            case 'Accept Crop'
                decision = 0;
            case 'Crop More' 
                decision = 1;
        end %end of Switch
    end %end of While
    close(F); %close the current figure

    % Save the start and stop points in a file called 15A.crop
    global analysisPath;
    %check if analysis path has been designated
    %the *.CROP file is save in the same folder as the processed *.mat file
    %with the phage trace, i.e. in the "analysisPath"
    if isempty(analysisPath);
        SetAnalysisPath;
    end

    Folder = [analysisPath '\' 'CropFiles']; %save the crop file in a separate folder in the analysisFolder
    if ~exist(Folder,'dir') %if this folder doesn't exist, create it
        mkdir(Folder); %create it
    end
    
    File   = [Phages(i).file(1:end-4) '.crop'];   %the name of the *.crop file with the proper extension
    FID = fopen([Folder '\' File],'w'); %this is the FileIdentification tag = FID
    fprintf(FID, '%f \n', start);
    fprintf(FID, '%f \n', stop);
    fclose(FID);
    disp(['Crop successfuly saved in ' File]);
    disp('--------------------------------------------');
end