function out = testNDependence(fcn, inData, trialX)
len = length(trialX);
out = zeros(1,len);
ran = inData(end)-inData(1);
dom = length(inData);

trialX = unique(floor(trialX));
for i = 1:len
    hei = trialX(i);
    testData = zeros(dom,hei);
    for j = 1:hei
        testData(:,j) = inData + (j-1)*ran;
    end
    testData = testData(:)';
    startT = tic;
    fcn(testData);
    out(i) = toc(startT);
    
end

figure('Name',sprintf('N dependence of %s',func2str(fcn)))
plot(trialX, out)