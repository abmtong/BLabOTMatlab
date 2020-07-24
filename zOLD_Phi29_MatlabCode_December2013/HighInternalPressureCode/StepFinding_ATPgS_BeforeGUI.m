function StepFinding_ATPgS_BeforeGUI(Action)
    % Correct Offset
    % Mark Peak1
    % Mark Peak2
    % Clear 
    % Save/Accept Trace
    % Ignore
    %
    % Gheorghe Chistol, 14 July 2011
    
    switch Action
        case 'CorrectOffset'
            global Peak1 Peak2 Offset X Y MaxInd;
            but = 1;
            while but == 1
                [x,~,~] = ginput(1);
                if ishandle(Offset.Handle)
                   delete(Offset.Handle);
                end
                %the nearest local maximum is the new offset
                temp = abs(X(MaxInd)-x);

                t = find(temp==min(temp),1,'first');
                Offset.Ind = MaxInd(t);
                Offset.Handle = plot(X(Offset.Ind)*[1 1],Y(Offset.Ind)*[0 1],'w','LineWidth',3);
                but=0;
            end

        case 'MarkPeak1'
            global Peak1 X Y MaxInd;
            but = 1;
            while but == 1
                [x,~,~] = ginput(1);
                if ishandle(Peak1.Handle)
                   delete(Peak1.Handle);
                end
                %the nearest local maximum is Peak1
                temp = abs(X(MaxInd)-x);

                t = find(temp==min(temp),1,'first');
                Peak1.Ind = MaxInd(t);
                Peak1.Handle = plot(X(Peak1.Ind)*[1 1],Y(Peak1.Ind)*[0 1],'r','LineWidth',2);
                but=0;
            end
        case 'MarkPeak2'       
            global Peak2 X Y MaxInd;
            but = 1;
            while but == 1
                [x,~,~] = ginput(1);
                if ishandle(Peak2.Handle)
                   delete(Peak2.Handle);
                end
                %the nearest local maximum is Peak2
                temp = abs(X(MaxInd)-x);

                t = find(temp==min(temp),1,'first');
                Peak2.Ind = MaxInd(t);
                Peak2.Handle = plot(X(Peak2.Ind)*[1 1],Y(Peak2.Ind)*[0 1],'m','LineWidth',2);
                but=0;
            end        

        case 'Clear'
            global Peak1 Peak2 Offset Status X Y MaxInd;
            Peak1.Ind = [];
            if ishandle(Peak1.Handle)
                delete(Peak1.Handle);
                Peak1.Handle = [];
            end
            Peak2.Ind = [];
            if ishandle(Peak2.Handle)
                delete(Peak2.Handle);
                Peak2.Handle = [];
            end              
            Offset.Ind         = MaxInd(1); %reset to the default value
            if ishandle(Offset.Handle)
                delete(Offset.Handle);
                Offset.Handle = [];  
            end
            Status = 'Ignore';

%         case 'SaveTrace'
%             global Peak1 Peak2 Offset Status;        
%             if ~isempty(Peak1.Ind) && ~isempty(Peak2.Ind) && ~isempty(Offset.Ind)
%                 Status = 'Save';
%             end

%         case 'Ignore'
%             global Peak1 Peak2 Offset Status;
%             Peak1.Ind     = [];
%             Peak1.Handle  = [];
%             Peak2.Ind     = [];
%             Peak2.Handle  = [];
%             Offset.Ind    = [];
%             Offset.Handle = [];
%             Status        = 'Ignore';
    end
end

