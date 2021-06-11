function out = randomCheck(indata, inOpts)

%Checks for randomness by some method

opts.method = 1; %Choose method
opts.ccdfxform = 1; %Convert data to [0, 1) ?

if opts.ccdfxform == 1
    %Transform indata to random [0,1) by ccdf y-value
    [~, ia] = sort(indata);
    rnd = (ia-1) / max(ia);
else
    rnd = indata;
end


switch opts.method
    case 1 %Split in two, 
        
        
    case 2 %Wald-Wolfowitz runs test
        med = median(rnd);
        
        
        
end

