function out = SearchStepNumbersHeaviside( Contour, Time, StepRange )
%Fits the [Time, Contour] data to @FunctionDwellBurst with varying number of steps decided by StepRange.
%Plots the data and various lines; outputs the fit values (see FunctionDwellBurst)

%NEXT: Try a Heaviside-style function- much fewer DOF


out = cell(1,length(StepRange));

for n = 1:length(StepRange)
    numSteps = StepRange(n);
    %Guess is an evenly stepped line from Time(1),Contour(1) to Time(end),Contour(end) with n steps (2n segments, every other slope 0)
    guessL = ones(1,numSteps)*(Time(end)-Time(1))/numSteps;
    guessH = linspace(Contour(1),Contour(end),numSteps);
    guess = [guessL' guessH'];
    %{
    lb = [guessL'/2 guessM'*2];
    lb(1,:) = guess(1,:)*0.9;
    ub = [guessL'*2 guessM'/2] ;
    ub(1,:) = guess(1,:) * 1.1;
    %}
    options = optimoptions(@lsqcurvefit, 'MaxFunctionEvaluations',10000*2*numSteps,'StepTolerance',1e-20,'MaxIterations',20000);
    fitParams = lsqcurvefit(@FunctionDwellBurst,guess,Time,Contour,[],[],options);
    

    %Plot fit steps
    %Create vector of x positions of boundary points
    
    l = fitParams(2:end,1);
    m = fitParams(2:end,2);
    x0 = fitParams(1,1);
    y0 = fitParams(1,2);
    
    x = zeros(length(l)+1,1);
    for i = 1:length(l)
        x(i+1) = sum(l(1:i));
    end
    %Offset each by the starting value
    x = x + x0;

    %Create vector of y positions of boundary points
    y = zeros(length(l)+1,1);
    for i = 1:length(l)
        y(i+1) = y(i) + l(i)*m(i);
    end
    %Offset each by the starting value
    y = y + y0;

    %Plot data
    figure('Name',[num2str(numSteps) ' steps'])
    plot(Time, Contour)
    hold on
    line(x,y);
    
    out{n} = fitParams;
end
    %{
    options = optimoptions(@lsqnonlin, 'MaxFunctionEvaluations','1000*numberOfVariables')
    lsqnonlin(@FunctionDwellBurst,x0,y,lb,ub,options)
    %}

end

