%old offset files, new processing

%[~, in] = findpeaks -diff(mx) minpeakheight +2 minpeakprominence +2
%have indicies of jumps, take off 10% of length on both sides
%take average as cal value

offAX = zeros(1,length(in)-1);
offMX = zeros(1,length(in)-1);
for i = 1:length(in)-1
    d = round((in(i+1)-in(i))/10);
    in1 = in(i) + d;
    in2 = in(i+1) - d;
    offAX(i) = mean(ax(in1:in2));
    offMX(i) = mean(mx(in1:in2));
end

plot(offMX,offAX)