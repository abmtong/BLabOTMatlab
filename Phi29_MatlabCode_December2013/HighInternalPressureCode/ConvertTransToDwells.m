function dwells = ConvertTransToDwells(trans)
%
% Converts transition information data structure to data structure for
% dwells. Jeff's code uses transition data, but that turns out to be
% inconvenient sometimes.
%
% USE; Dwells = ConvertTransToDwells(Transitions); 
%
% Gheorghe Chistol, 25 Oct 2010

for i=1:length(trans)
    for j=1:length(trans(i).mean)
        
        %denote the start of a dwell
        if j==1
            %this is the first dwell
            dwells(i).start(j)=1;
        else
            %the dwell starts when the transition occurs
            dwells(i).start(j)=trans(i).cidx(j-1);
        end
        
        %denote the end of a dwell
        if j==length(trans(i).mean)
            %this is the last dwell
            dwells(i).end(j)=trans(i).cidx(j-1)+trans(i).Npts(j);
        else
            %the dwell starts when the transition occurs
            dwells(i).end(j)=trans(i).cidx(j)-1;
        end
    end
    
    %copy the rest without modification, leave out trans.wid, of no use now
    dwells(i).mean = trans(i).mean;
    dwells(i).std = trans(i).std;
    dwells(i).Npts = dwells(i).end-dwells(i).start+1;
end

