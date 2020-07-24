filterProps = zeros(1,100);
for i = 1:length(filterProps)
    [len, mean] = AFindSteps(medianFilter(testContour,i));
    filterProps(i) = length(mean);
end
plot(filterProps)
