 
function [VectorFC] = FCMaker(TrapX,Time,Vector)

    %Filters down the data to make easy the analysis and smooth down the
    %section where the mirror is not moving

    DTrapX=[0 diff(TrapX)'];
    DTrapX=DTrapX';
    FDTrapX=FilterAndDecimate(DTrapX,100);
    FTime=FilterAndDecimate(Time,100);


    %Finds when the mirror voltage is changing. Finds the middle value (Mtime) to estimate when the mirror position is changing. 
    MTime=[];sum=0; counter=1;
     for i=2:length(FDTrapX)
        if FDTrapX(i)< -0.25 %This value is a threshold. If the program is finding too many FC it is possible this is not the right number
            if (FDTrapX(i-1)-FDTrapX(i))< 1
                if counter==1
                sum=FTime(i-1) + FTime(i);
                else 
                sum=sum+FTime(i);
                end
            %disp(sum)
            counter=counter+1; 
            %disp(counter);
            end
        else
            if counter>1;
            MTime=[MTime sum/counter];
            counter=1;
            sum=0;
            end
        end
     end

     %Uses the middle time estimation to find that time in the vector filter
     %vector
     ClosestValue=[]; ListIndex=[];
     for i=1:length(MTime)
         [c index] = min(abs(FTime-MTime(i)));
         ListIndex=[ListIndex index];
         ClosestValue = [ClosestValue FTime(index)]; 
     end

     UFListIndex=[];
     for i=1:length(ListIndex)
         [c index] = min(abs(Time-FTime(ListIndex(i))));
         UFListIndex=[UFListIndex index];
     end

     for i=1:length(UFListIndex)
         if i==1
            VectorFC{i}=Vector(1:UFListIndex(i));
             else
            VectorFC{i}=Vector(UFListIndex(i-1)+1:UFListIndex(i));
         end
     end

 
end
 
 