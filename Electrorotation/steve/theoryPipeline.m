%This script will intake a series of measurements of the generalized
%friction, the assocaited rotational positions, and the number of bins in a
%single rotational sampling and produce a model fit of the three-fold
%friction as well as the optimal velocity profile and a measure fo the weighted RMSE
%
%Steven Large
%August 30th 2019

function[meanFric,errFric,optVel,errVel,wRMSE,fitresult] = theoryPipeline(frictionArray,trapPos,numPos)


binWidth = 1/numPos;
%{
binCounter = -0.5*binWidth;
binEdges = {};
binCenters = {};

%Define the bin edges and bin centers for comparing friction values
for index=1:numPos+1
   binEdges{index} = binCounter;
   binCounter = binCounter + binWidth;
end
binEdges = [binEdges{:}];
%}

%The above lines are equivalent to:
binEdges = ((0:numPos+1) - .5) * binWidth;
binCenters = binEdges(1:end-1) + .5*binWidth;

for index=1:numPos
    binCenters{index} = binEdges(index) + 0.5*binWidth;
end
binCenters = [binCenters{:}];

%Find which friction values fall within each of the bins
friction = {};
for index1=1:numPos
   tempCell = {};
   cellCounter = 1;
   for index2=1:length(frictionArray)
      if(mod(trapPos(index2),1)>binEdges(index1) && mod(trapPos(index2),1)<binEdges(index1+1))
          tempCell{cellCounter} = frictionArray(index2);
          cellCounter = cellCounter + 1;
      end
      friction{index1} = [tempCell{:}];
   end
end

meanFric = {};
errFric = {};

%Use the jackKnife routine to calculate the mean and standard error of the
%mean for the friction data
for index=1:numPos
   [jackMean,jackErr] = JackKnifeMean(friction{index});
   meanFric{index} = jackMean;
   errFric{index} = jackErr;
end
meanFric = [meanFric{:}];
errFric = [errFric{:}];

%Calculate the inferred optimal velocities and assocaited errors
optVel = 1./sqrt(meanFric);
errVel = sqrt(0.25.*(meanFric.^(-3)).*(errFric.^2));

%% FITTING ALGORITHM
[xData, yData, weights] = prepareCurveData( binCenters, meanFric, 1./errFric);

% Set up fittype and options.
ft = fittype( 'a0 + a1*sin(6*pi*x) + a2*cos(6*pi*x)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.15 0.25 0.84];
opts.Weights = weights;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

%Calculate the weighted RMS error in the friction fit
wRMSE = sqrt((1.0/sum(weights)).*sum(transpose(weights).*((meanFric - transpose(fitresult(binCenters))).^2)));

%CAlculate the expected work ratio from the experimental measurements and
%the model predictions
%workRatio_exp = mean(meanFric)/(mean(sqrt(meanFric)).^2);
%workRatio_model = mean(modelFric)/(mean(sqrt(modelFric)).^2);

%
%==========================Plotting routines===============================
%

%Evaluate model fit on an array of x-values between 0 and 1
xArray = [0:0.01:1];
modelFric = fitresult(xArray);
modelVel = 1./sqrt(modelFric);

subplot(2,1,1)
hold on
h1 = plot(mod(trapPos,1),frictionArray,'k.');
h2 = plot(binCenters,meanFric,'b');
h3 = errorbar(binCenters,meanFric,errFric,'bo');
h4 = plot(xArray,modelFric,'r');

subplot(2,1,2)
hold on
g1 = plot(binCenters,optVel,'b');
g2 = errorbar(binCenters,optVel,errVel,'bo');
g3 = plot(xArray,modelVel,'r');

h1.MarkerSize=10;
h2.LineWidth=2.0;
h3.LineWidth=2.0;
h4.LineWidth=3.0;

g1.LineWidth=2.0;
g2.LineWidth=2.0;
g3.LineWidth=3.0;

xlabel('Trap minimum \lambda/2\pi');
ylabel('Optimal velocity');
set(gca,'FontSize',17);
subplot(2,1,1)
ylabel('Friction \zeta(\lambda)')
set(gca,'FontSize',17);


