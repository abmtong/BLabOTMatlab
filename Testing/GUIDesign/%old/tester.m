%These are all with different filters, PF = 9*estimateNoise(unfiltered)
                                           %mean sd   %burr a b c
%BatchFindSteps(@gaussMean, 5, 1, 'G0501'); %7.7 3.6   7.7  3.8 1.3
%BatchFindSteps(@gaussMean, 3, 1, 'G0301'); %9.6 4.2   8.2  4.9 .83
%BatchFindSteps(@gaussMean, 7, 1, 'G0701'); %6.7 3.3   6.7  3.6 1.3
%BatchFindSteps(@gaussMean, 5, 2, 'G0502'); %10.5 4.9  8.96 3.4 .83
%BatchFindSteps(@gaussMean, 3, 2, 'G0302'); %12.4 5.3  9.85 5.5 .64
%BatchFindSteps(@gaussMean, 7, 2, 'G0702'); %9.5 4.5   8.96 4.5 .83
wb = waitbar(0,'G');
waitbar(.3,wb,'M');
BatchFindSteps(@mean, 5, 1, 'M0501');
BatchFindSteps(@mean, 3, 1, 'M0301');
BatchFindSteps(@mean, 7, 1, 'M0701');
BatchFindSteps(@mean, 5, 2, 'M0502');
BatchFindSteps(@mean, 3, 2, 'M0302');
BatchFindSteps(@mean, 7, 2, 'M0702');

waitbar(.6,wb,'N');
BatchFindSteps(@median, 5, 1, 'N0501');
BatchFindSteps(@median, 3, 1, 'N0301');
BatchFindSteps(@median, 7, 1, 'N0701');
BatchFindSteps(@median, 5, 2, 'N0502');
BatchFindSteps(@median, 3, 2, 'N0302');
BatchFindSteps(@median, 7, 2, 'N0702');
figure; plot(randn(1:1000));