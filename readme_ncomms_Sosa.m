%readme_ncomms_Sosa
%{
This is a readme for the code for the paper The Central Coupler of the AAA+ ATPase ClpXP Controls Intersubunit Communication and Couples the Conversion of Chemical Energy into the Generation of Force in Nature Communications.

Raw instrument data are converted to force and extension via ./RawDataProcessing/AProcessDataV2.m

Traces are analyzed using ./Misc/ClpX/cxripV2.m
 The analysis uses the stepfinding algorithm from this paper by Kalafut and Visscher: http://dx.doi.org/10.1016/j.cpc.2008.06.008

To test the efficacy of this method, we did testing on simulated data, the code of which can be found in ./Misc/ClpXSimulation/

For more information, contact authors R. Sosa or A. Tong.
%}