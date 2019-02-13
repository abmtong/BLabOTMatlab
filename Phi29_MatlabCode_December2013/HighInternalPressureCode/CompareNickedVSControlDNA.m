load Nicked_vs_Control_DNA_21kb_ATP500uM;
%ControlDNA
%NickedDNA

Data         = NickedDNA;
NickVel      = [];
NickVelStErr = [];
NickFilling  = [];
for b=1:length(Data.Start)
    if ~isempty(Data.Velocity{b})
        NickVel(end+1)      = mean(-Data.Velocity{b});
        NickVelStErr(end+1) = std(-Data.Velocity{b})/sqrt(length(-Data.Velocity{b}));
        NickFilling(end+1)  = mean(Data.Start(b),Data.End(b));
    end
end

Data          = ControlDNA;
ContrVel      = [];
ContrVelStErr = [];
ContrFilling  = [];
for b=1:length(Data.Start)
    if ~isempty(Data.Velocity{b})
        ContrVel(end+1)      = mean(-Data.Velocity{b});
        ContrVelStErr(end+1) = std(-Data.Velocity{b})/sqrt(length(-Data.Velocity{b}));
        ContrFilling(end+1)  = mean(Data.Start(b),Data.End(b));
    end
end

figure; hold on;
errorbar(ContrFilling,ContrVel,ContrVelStErr,'.k');
errorbar(NickFilling,NickVel,NickVelStErr,'.','Color',[0.7 .7 .7]);
legend('Control DNA','Nicked DNA');
xlabel('Capsid Filling (bp)');
ylabel('Pause Free Velocity (bp/sec)');
title('Nicked vs Control DNA, 500uM ATP, StdErrs shown, 20 traces each')