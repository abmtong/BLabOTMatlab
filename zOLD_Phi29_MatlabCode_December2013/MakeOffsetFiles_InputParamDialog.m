function Param = MakeOffsetFiles_InputParamDialog(Title,Prompts,DefaultParams)
% This is a helper function used to get parameters from the user via a
% Graphical User Interface dialog. This is useful especially when there are
% several parameters that we might want to change such as bead size,
% filtering frequency, pause duration, etc. This replaces the old function
% "getnumbers.m". 
%
% USE: Param = MakeOffsetFiles_InputParamDialog(Title,Prompts,DefaultParams)
%
% Gheorghe Chistol, 09 Feb 2012

    Options.Resize      = 'off';
    Options.WindowStyle = 'modal';
    Options.Interpreter = 'tex';

    Output = inputdlg(Prompts,Title,1,DefaultParams,Options);    
    if isempty(Output)
        error('InputParamDialog: No input was provided :('); %abort if the user cancels and no data was given
    end
    
    Param = NaN(1,length(Output)); %initialize vector
    for i=1:length(Output)	
        Param(i) = str2double(Output{i});
    end
    
end