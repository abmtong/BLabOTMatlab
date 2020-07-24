function outSteps = getStepSizes(inStaircase)
d = diff(inStaircase);
outSteps = d(d~=0); %keep negative so iteration works
end