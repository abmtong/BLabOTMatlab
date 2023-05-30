function out = alignSpots(inst)

%Okay let's try to find a way to merge spots:

%Use a seed frame that is 'good':

%For every spot in this frame, check fwd/back for spots that overlap it [maybe expand the spots in question]

%Consider these the 'same' and connect

%How to tell which spots are the same?
% Simple method is to recreate both regions and take their &
% Check for a close centroid? i.e. closest + within N px

%Might be easiest to consider BoundingBoxes:
% Elegant way to check if two BBs overlap?
%BB = [x y dx dy] ; bb2 = [x2 y2 dx2 dy2]

% BB1x is x to x+dx ; BB2x is x2 to x+dx2 ; these intersect if any( bb2(1) < bb1 & bb2(2) > bb1 ); might be faster with scalar gt && lt || gt && lt

%For every spot..
len = length(inst(ind));
for i = 1:len
    
    %Assemble the centroid over time trace
    cens = cell(1,len);
    
    cens{ind} = inst(ind).rprops.cen(i);
    curcen = cens{ind};
    
    switch method
        case 1 %Nearest centroid
            cenmaxd = 5; %Maximum jitter of this many pixels
            
            %Go forwards in time...
            for j = ind+1:nfr
                %Get centroids of next frame
                tmpcen = [inst(ind).rprops.cen];
                %Take distance
                
                
            end
            
            
            %Go backwards in time..
            
            
    end
    
end