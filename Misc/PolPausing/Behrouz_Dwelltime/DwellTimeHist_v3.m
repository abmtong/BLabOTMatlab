
function [DWT_hist]=DwellTimeHist_v3(DWT_array, t0, bins)

Nbins = length(bins);

sum_hist=zeros([1,Nbins-1]);

sum=0;

num=0;

for j=1:length(DWT_array)
    
    DWT=DWT_array(j)-(t0/2);
    
    num=num+1;
        
    for i=1:Nbins-1
            
        if ((DWT >= bins(i)) && (DWT < bins(i+1)))
            
            sum_hist(i)=sum_hist(i)+(bins(i+1)-bins(i))^(-1);
        end
    end
    
end

DWT_hist=sum_hist/num;

for i=1:(Nbins-1)
    sum=sum+(DWT_hist(i)*(bins(i+1)-bins(i)));
end

