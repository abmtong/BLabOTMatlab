function [tr, realst] =simtracehmm
    %simulate trace data
    realmu = 10;
    realsig = realmu/2;
    %two options: stay, or hop forwards
    reala = [.99 .1];
    len = 2e3;
    realst = zeros(1,len);
    realst(1) = 1; %start in state 1
    for i = 2:len
        %roll dice
        switch find(rand(1) < cumsum(reala),1)
            case 2
                dst = realmu;
            otherwise
                dst = 0;
        end
        realst(i) = realst(i-1)+dst;
    end
    tr = realst + randn(1,len)*realsig;