function AnalyzeHistogramBinning = HistogramAnalysis(Bursts)
% Create directory name and actual directory
global analysisPath;
 prompt = {'What is the penalty factor?'};
    PenaltyFactor = 'Input';
    num_lines = 1;
    def = {'3'};
    PF = inputdlg(prompt,PenaltyFactor,num_lines,def);
    if strcmp('3',PF);
        PenFact=3;
    elseif strcmp('5',PF);
        PenFact=5;
    end;
    
Name=['AnalyzeHistogramBinning_Images_PF_' num2str(PenFact)]; 
display (Name)
    
ImageFolderName=[analysisPath filesep Name];
display(ImageFolderName)
if ~isdir(ImageFolderName);
        mkdir(ImageFolderName); %create the directory
end
%plot canonical histogram [2.5 5 7.5 10 12.5 15] and saves it

 prompt = {'If this is the WT motor type W. If this is the mutant motor type M'};
    TypeOfMotor = 'Input';
    num_lines = 1;
    def = {'W'};
    answer = inputdlg(prompt,TypeOfMotor,num_lines,def);
    if strcmp(answer,'W')==1
        lColor=[0 0 1];
        MotorName='WT';
    elseif strcmp(answer,'M')==1
        lColor=[1 0 0];
        MotorName='F145I';
    end
    
  
%Create normalized histogram
HistNo1=hist(Bursts.Size,[2.5 5 7.5 10 12.5 15]);
suma=sum(HistNo1);
HistNo1Norm=HistNo1/suma;
close all;
% Create bar
figure; 
bar([2.5 5 7.5 10 12.5 15],HistNo1Norm,...
    'DisplayName',[MotorName,sprintf('\n'),'10 uM ATP'],'FaceColor',lColor);
% Create xlabel
xlabel('Step size (bp)','FontSize',16);
% Create ylabel
ylabel('Percentage frequency (a.u.)','FontSize',16);
% Create legend
legend1 = legend(gca,'show');
set(legend1,'EdgeColor',[1 1 1],'YColor',[1 1 1],'XColor',[1 1 1], 'FontSize',10');
set(gca,'XTick',[2.5 5 7.5 10 12.5])
xlim([0 16]);

ImageFileName = [ImageFolderName filesep 'HistogramBinning2_5bp.png'];
saveas(gcf,ImageFileName); 
ImageFileName = [ImageFolderName filesep 'HistogramBinning2_5bp.fig'];
saveas(gcf,ImageFileName); 

n=[1 2 4 8];
HistogramNo=[4,]; 
for i=1:4; 
        Bin=n(i)*0.25;
        %display(Bin);
        Temporal=hist(Bursts.Size,[1:Bin:16]);
       % HistogramNo(i,:)=Temporal;
        suma=sum(Temporal);
        Temporal=Temporal/suma;
        figure(2);
        set(2,'Position', [100,50,1200,600]);
        hold on;
        subplot(2,2,i);
        bar([1:Bin:16],Temporal,...
         'DisplayName',[num2str(Bin) 'bp bin'],'FaceColor',lColor);
        % Create xlabel
        xlim([0 16]);
        xlabel('Step size (bp)','FontSize',12);
        % Create ylabel
        ylabel('Percentage frequency (a.u.)','FontSize',12);
        title('Step size histogram','FontSize',12);
        legend1 = legend(gca,'show');
        set(legend1,'EdgeColor',[1 1 1],'YColor',[1 1 1],'XColor',[1 1 1], 'FontSize', 10);
        if i>2
            set(gca,'XTick',[0:Bin:16])
        end
        hold off;
        figure;
        bar([1:Bin:16],Temporal,...
         'DisplayName',[MotorName,sprintf('\n'),'10 uM ATP'], 'FaceColor',lColor);
        % Create xlabel
        xlim([0 16]);
        xlabel('Step size (bp)','FontSize',16);
        % Create ylabel
        ylabel('Percentage frequency (a.u.)','FontSize',16);
        % Create legend
        title('Step size histogram','FontSize',16);
        % legend1 = legend(axes1,'show');
        % set(legend1,'EdgeColor',[1 1 1],'YColor',[1 1 1],'XColor',[1 1 1]);
        legend1 = legend(gca,'show');
         if i>2
            set(gca,'XTick',[0:Bin:16])
        end
        set(legend1,'EdgeColor',[1 1 1],'YColor',[1 1 1],'XColor',[1 1 1], 'FontSize',10');
        ImageFileName = [ImageFolderName filesep 'HistogramBinning' num2str(Bin) 'bp.png'];
        saveas(gcf,ImageFileName); 
        ImageFileName = [ImageFolderName filesep 'HistogramBinning' num2str(Bin) 'bp.fig'];
        saveas(gcf,ImageFileName);
       
end
     ImageFileName = [ImageFolderName filesep 'HistogramBinningSummary.png'];
        saveas(2,ImageFileName); 
     ImageFileName = [ImageFolderName filesep 'HistogramBinningSummary.fig'];
        saveas(2,ImageFileName); 

end