function testerTime(inContour)

indSta = 1000;
indEnd = 2000;

len = indEnd - indSta + 1;
pointVars = zeros(1, len);


conSlice = inContour(indSta:indEnd);
for j = 1:len
    pointVars(j) = var(conSlice(1:j-1)) + var(conSlice(j:end)); 
end
%     
% for j = 1:len
%     pointVars(j) = var( inContour(indSta  :indSta+j-1))...
%                  + var( inContour(indSta+j:indEnd    ));
% end