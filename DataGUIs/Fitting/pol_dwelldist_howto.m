%{
pol_dwelldist_howto

Step 1: Crop traces in PhageGUI
 see PhageGUI usage

Step 2: Assemble raw data struct
 Extract traces using getFCs:
  data1 = getFCs(); %Select trace, set 1
  data2 = getFCs(); %Select trace, set 2
  %etc.
 Assemble them to a struct by condition, e.g.
  rawdata.condition1 = data1;
  rawdata.condition2 = data2;

Step 3: Run dwellfinding
 Create options structure, good starting point for assisting force (comment for opposing force)
  opts.Fs = 1000; %Your Fs
  opts.dir = 1; %-1 for opposing
  opts.fvopts.trnsprb = [1e-3 1e-100]; %[1e-100 1e-3] for opposing
 Then run:
  [afit, afbt] = pol_dwelldist_p1(rawdata, opts);

Step 4: Run dwellfitting
  bfit = pol_dwelldist_p2(afit);
   This outputs figures of the fits and two .xls in the working dir with stats
%}

