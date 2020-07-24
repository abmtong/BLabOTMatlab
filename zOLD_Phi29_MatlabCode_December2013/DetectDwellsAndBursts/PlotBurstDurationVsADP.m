ADP = [0 250 500 750 1000 1500];

LowerLimit = [0.0237 0.0204 0.0199 0.0186 0.0181 0.0182];
Mean       = [0.0256 0.0224 0.0212 0.0201 0.0195 0.0221];
UpperLimit = [0.0276 0.0240 0.0227 0.0218 0.0212 0.0261];

errorbar(ADP,Mean,Mean-LowerLimit,UpperLimit-Mean,'.b');

set(gca,'YLim',[0 0.04]);
xlabel('ADP Concentration (uM)');
ylabel('Burst Duration (s)');