function ForceExt_FitCropData(CropForce,CropExtension,FileName,Tstart,Tstop)
% This function is given CropForce and CropExtension arrays and it fits the
% worm-like chain to the data. This assumes that CropForce and
% CropExtension are in the linear regime of the trap.
%
% USE: ForceExt_FitCropData(CropForce,CropExtension,FileName)
%
% Gheorghe Chistol, 10 Feb 2012

    %OriginalFigH = gcf;
    %Data = guidata(OriginalFigH); %get the data
    H  = figure('Units','normalized','Position',[0.5095    0.1237    0.3990    0.7721]);
    set(gcf,'Tag','ForceExtFitFigure'); % we can use this later to find and close all these figures
    plot(CropExtension,CropForce,'.b','MarkerSize',.5);
    ylabel('Force (pN)');
    xlabel('Extension (nm)');
    title(FileName,'Interpreter','none');

    % Prompt for Calibration Parameters
    Prompts  = {'Fitting Range: Low Force Limit (pN)',...
                'Fitting Range: High Force Limit (pN)',...
                'Data Plotting Range: Low Force Limit (pN)',...
                'Data Plotting Range: High Force Limit (pN)',...
                'Fit Plotting Range: Low Force Limit (pN)',...
                'Fit Plotting Range: High Force Limit (pN)'};
    DefaultParams = {'2',  '20', ...
                     '1.5','45',...
                     '1.5',  '45'}; 
    Params = ForceExt_InputParamDialog('Fitting Parameters: ', Prompts, DefaultParams);
    close(H);
    FitFmin = Params(1); 
    FitFmax = Params(2); 
    PlotDataFmin = Params(3);
    PlotDataFmax = Params(4);
    PlotFitFmin = Params(5);
    PlotFitFmax = Params(6);
    
    
    IndStart = find(CropForce>FitFmin,1,'first');
    IndEnd   = find(CropForce<FitFmax,1,'last');
    Force     = double(CropForce(IndStart:IndEnd))';
    Extension = double(CropExtension(IndStart:IndEnd))';
    
    %% Define the guess values for the fit
    % aGuess     = [PersLength(nm) StretchModulus(pN) ContourLength(bp)  ExtensionOffset(nm) ForceOffset(pN)];
    aGuess     = [53  1200 3125  0  0];
    %A Gonna fool with some of these bounds a bit
%     LowerBound = [10  1200 1000  -.1 -1]; 
%     UpperBound = [100 1201 10000 +.1 +1];
    %             PL  Ela  ConL  OffX OffF
    LowerBound = [10  0000 2000 -1  -1]; 
    UpperBound = [100 2000 6000 +1  +1];
    
    
    Options    = optimset('TolFun',1e-10,'MaxIter',10000); %define the options for fitting

    [a,ResNorm,Residual,ExitFlag,Output] = lsqcurvefit(@ForceExt_FunctionWLC,aGuess,Force,Extension,LowerBound,UpperBound,Options);
% 
%     %How well does this fit? Search params constricting?
%     disp(LowerBound)
%     disp(a)
%    % disp(ResNorm)
%     disp(UpperBound)
%     
    fprintf('PL=%0.2fnm, SM=%0.1fpn, CL=%0.1fbp, OffExt=%0.2fnm, OffFor=%0.2fpN\n', a);
    
    a=real(a);
    
    ExpectedExtension = ForceExt_FunctionWLC(a,Force);
    ResidualErr = (Extension./ExpectedExtension-1)*100; %the residual error in %
    
    %% Figure out what Fit/Data portions to use
    PlotFitForce = PlotFitFmin:.1:PlotFitFmax; %use to plot the fit
    PlotFitExten = ForceExt_FunctionWLC(a,PlotFitForce); %use to plot the fit
    
    IndStart = find(CropForce>PlotDataFmin,1,'first');
    IndEnd   = find(CropForce<PlotDataFmax,1,'last');
    PlotDataForce = CropForce(IndStart:IndEnd);
    PlotDataExten = CropExtension(IndStart:IndEnd);

    %% Plot Fit Results
    figure('Units','normalized','Position',[0.5095    0.1237    0.3990    0.7721]);
    set(gcf,'Tag','ForceExtFitFigure'); % we can use this later to find and close all these figures
    subplot(3,1,[1 2]); hold on;
    plot(PlotDataExten,PlotDataForce,'Color',0.8*[1 1 1],'LineWidth',3); 
    plot(Extension,Force,'Color',0.6*[1 1 1],'LineWidth',3); %strictly the raw data used for the fit
    plot(PlotFitExten,PlotFitForce,'k','LineWidth',1); %plot the fit results
    set(gca,'YLim',[0 max(PlotDataForce)*1.05]);
    set(gca,'XLim',[min(PlotDataExten)-range(PlotDataExten)*0.05 max(PlotDataExten)+range(PlotDataExten)*0.05]);
    set(gca,'Box','on');
    ylabel('Force (pN)'); xlabel('Extension (nm)')
    
    if nargin==3
        %Tstart and Tstop not specified
        title([FileName],'Interpreter','none','FontWeight','bold');
    elseif nargin==5
        %Tstart and Tstop were specified
        title([FileName, ' [ ' num2str(Tstart,'%3.2f') 's - ' num2str(Tstop,'%3.2f') 's ]' ],'Interpreter','none','FontWeight','bold');
    end
    
    subplot(3,1,3); hold on;
    plot(Force, ResidualErr,'.m','MarkerSize',2);
    plot(get(gca,'XLim'),[0 0],'k','LineWidth',1);
    YLim=max(abs(ResidualErr));
    set(gca,'YLim',[-YLim +YLim]); 
    set(gca,'Box','on');
    xlabel('Force (pN)');
    ylabel('Residual Err (%)');
    
    ResultsSummary = (['P = ' num2str(a(1),'%2.1f') ' nm \newline ' ...
                       'L = ' num2str(a(3),'%4.0f') ' bp \newline ' ...
                       'F_0 = ' num2str(a(5),'%1.2f') ' pN \newline ' ]);
   
    annotation(gcf,'textbox', [0.149 0.585 0.359 0.315],...
                   'FitBoxToText','on','FontWeight','bold', 'String', ResultsSummary,'Interpreter','tex');
%    disp(['--------------------------------------------']);
%    disp(['  Persistence Length (nm)  ' num2str(a(1),'%2.1f') ]);
%    disp(['  Stretch Modulus (pN)     ' num2str(a(2),'%4.0f') ]);
%    disp(['  Contour Length (bp)      ' num2str(a(3),'%4.0f') ]);
%    disp(['  Extension Offset (nm)    ' num2str(a(4),'%3.0f') ]);
%    disp(['  Force Offset (pN)        ' num2str(a(5),'%1.2f') ]);
%    disp(['--------------------------------------------']);
end