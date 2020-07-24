function Data = uTabulateStiffness()
    global analysisPath;
    [File Path] = uigetfile([analysisPath filesep '*al*.mat'],'MultiSelect','on');
%     Data.kAY    = nan(1,length(File));
%     Data.kAYstd = nan(1,length(File));
%     Data.kBY    = nan(1,length(File));
%     Data.kBYstd = nan(1,length(File));
%     Data.Ind    = nan(1,length(File));
    Data.kAY = [];
    Data.kBY = [];
    Data.aAY = [];
    Data.aBY = [];
    Data.aAX = [];
    Data.aBX = [];
    Data.V   = [];
    
     MinV = 5;
     MaxV = 10;
    for f=1:length(File)
        clear cal;
        load([Path filesep File{f}]);
%         Data.kAY(f)    = mean(cal.kappaAY_list);
%         Data.kAYstd(f) = std(cal.kappaAY_list);
%         Data.kBY(f)    = mean(cal.kappaBY_list);
%         Data.kBYstd(f) = std(cal.kappaBY_list);
%         Data.Ind(f)    = str2num(File{f}(11:end-4));
        Data.kAY = [Data.kAY cal.kappaAY_list];
        Data.kBY = [Data.kBY cal.kappaBY_list];
        Data.aAY = [Data.aAY cal.alphaAY_list];
        Data.aBY = [Data.aBY cal.alphaBY_list];
        Data.aAX = [Data.aAX cal.alphaAX_list];
        Data.aBX = [Data.aBX cal.alphaBX_list];
        
        Data.V   = [Data.V str2num(File{f}(11:end-4))/100*ones(1,length(cal.kappaBY_list))];
        KeepInd  = Data.V>=MinV & Data.V<=MaxV;
        Data.ScaledKY = [Data.kAY/mean(Data.kAY(KeepInd)) Data.kBY/mean(Data.kBY(KeepInd))];
        Data.ScaledAY = [Data.aAY/mean(Data.aAY(KeepInd)) Data.aBY/mean(Data.aBY(KeepInd))];
        Data.ScaledAX = [Data.aAX/mean(Data.aAX(KeepInd)) Data.aBX/mean(Data.aBX(KeepInd))];
        Data.ScaledV = [Data.V Data.V];
    end
end