function out = RPzerohopPopup

%Ask basic things: Protein length, intermediates ... else?


%Just do it in an inputdlg

%Protein size

%Intermediates

%Boundaries (Length = ints + 1)

qs = {'Protein Size? (nm) [opts.pwlcc]' 'Intermediate Locations? (Array, nm) [opts.lines]' 'Int Boundaries (Array, nm) [opts.tpint]' 'Data Size (pts window) [opts.wid]'};
as = {'107 * 0.35' '[ 0 10 40 ]' '[ -4 5 20 40 ]' '[ 5 1000 ];'};


resp = inputdlg(qs, 'RP Zero Hop Options', 1, as);


opts.pwlcc = str2num(resp{1}); %#ok<*ST2NM>
opts.lines = str2num(resp{2});
opts.tpint = str2num(resp{3});

out = opts;
