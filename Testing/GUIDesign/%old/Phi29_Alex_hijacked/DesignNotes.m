%To Measure
%{
X, Y Offset
 Seems to be ~[1.34,0.9] but how can we measure this? Bead at A(0,0) vs. B? Does A(0,0) reach behind (to the left of) trap B?
>> 1.4, 0.9

%}

%MATLAB Processing Changes
%{
Raw Data
Calibration in one 32mb file, an 8x[]x200 array
Offset in one 20kb file, an 8x[]x2 array
Data in one [variable length] file, a nSampx8x[] array

Analysis
00 02 01 comment = data offset cal works fine

General
calMMDDYYN##.mat or MMDDYYN##cal.mat ?
Keep backwards compatability? Ghe's variable names are garbage
Convert to double? Some fcns dont like singles, but doubles filesize

Data to save
General
 Timestamp = datetime(now);
 Path to source files
Calibration
 Necessary: alpha, kappa
 Debug: fit, opts
Offset
 {A B M} x {X Y}, {A B} x {S Xn Yn}
ForExt
 For, Con
Phage
 For{}, Con{}, time{}
Maybe just save everything, since space is cheap (Will give you reason to delete .dat files, too)s

Algorithms
Phage
 Segment Detection
  diff(MX)
   MX varies by ~.004 max over 10s (=max - min of cal file)
   Ghe uses .02 as thresh. for movement
   +: Need nothing extra
   -: Sometimes ~10pt segments slip through, why?
  Sensor
   Just output a 1/0 when moving/still. Ignore all 1s + 40ms buffer on end
   +: Exact bounds
   -: Extra files

%}

%MATLAB Analysis Changes
%{
PhageGUI
 Display trace and segments
 Crop utility, to set up batch data processing
  Crop utility should show force, to separate segments
 Pretty well fleshed out rn, add support for ChiSq method
ForExtGUI
 Display F-X and F-T
 Crop, fit to WLC with params
 Maybe have some output to save calc'd WLC param.s
%}

%LabVIEW VI Changes
%{
Color schemes
 Background color, Graph background color
 Text color? Plot line color?

Some way to break tether without taking data (save on space etc.)
 Output to AcquireData is final Mirror X, Y? might work (-> Set this to cursor)
%}





