function outSIC = testCounterfit( inContour, inSteps )
% Tests a counterfit, where steps are placed at the middle of the plateaus. Will have one extra step, by definition.
delta = round(diff(inSteps)/2);
newSteps = [1 delta+inSteps(1:end-1) length(inContour)];
newVar = zeros(1,length(newSteps)-1);
for i = 1:length(newVar)
    newVar(i) = var( inContour( newSteps(i):newSteps(i+1)-1 ));
end
outSIC = calculateSIC(newVar,length(inContour),1);

end

