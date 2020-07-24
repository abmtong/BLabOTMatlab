function [T P] = z_ComputeCumulativeDistribution(Duration)
%
% use: [T P] = z_ComputeCumulativeDistribution(Duration)
%
% Gheorghe Chistol, 10 Dec 2012

    Duration = sort(Duration);
    
    P = zeros(1,length(Duration));
    T = zeros(1,length(Duration));
    for i=1:length(Duration)
        P(i)=i/length(Duration);
        T(i)=Duration(i);
    end

    P = [0 P];
    T = [0 T];
    %plot(T,P,'b');
end