%Instrument Upgrades (Hardware)
%{
Current DAQ card (M Series)
7.5kHz noise: ~12bp @ 7pN, 4kb ext; 3.5bp@30pN, 2kb ext
62.5kHz noise: ~6bp @ 7pN, 4kb ext; 2.2bp@30pN, 3kb ext

Easy in-place upgrade: (X Series)
500kS/s -> 2MS/s
$1500 PCI-6361 (ebay: $650)
  4x samples, which should 1/2 noise
  cf previous change from 7.5kHz -> 62.5kHz (~9x samples, 1/3 noise) which actually ~halved noise.
    At this rate, the leftover signal is 1:1 signal:removable noise, and halving again would reduce it by 25% more
  Nothing says the BNC2090 doesn't work with the new card - might still work
250kHz noise: ~4.5bp @7pN (guess)
^This means bp accuracy at 30-35pN

More involved upgrade: (S series)
There exist detectors that do 2.5MS/s/ch, meaning 40x samples, but are differential only.
  There's some issue having differing grounds, which probably means it's unfeasible
  The QPDs are probably ungrounded, but the mirror probably is - we'll have ground leakage
  Removable noise would be essentially gone, ratio 1:0.15 (halve the noise again)
$3600 PCI-6133 (no ebay)
2.5mHz noise: ~3bp@7pN
^This means bp accuracy at 20-25pN

Unlikely, but may need the BNC 2090A
$500 BNC 2090A  (ebay: $200)

Computer
plz

%}

%Analysis tricks
%{
Reprocess all of Dec/May data

Try splitting 7-12pN data in two - 7-10 vs 10-12 noise is vastly different




%}