for i=1:length(Bin.Start)
    %plot((Bin.Start(i)+Bin.End(i))/2, mean(Bin.Velocity{i}),'ok');
    Filling(i)=(Bin.Start(i)+Bin.End(i))/2000;
    Velocity(i) = mean(Bin.Velocity{i});
    Error(i) = std(Bin.Velocity{i})/sqrt(Bin.SampleNumber(i));
end
