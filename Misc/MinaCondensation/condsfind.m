function out = condsfind(inst, inOpts)

%Takes input struct, does kdfsfind on them

opts.fpre = {10,1}; %pre filter
opts.binsz = 0.1; %bin size, for kdf and hist
opts.kdfsd = 1; %kdf gaussian sd
opts.histdec = 2; %Step histogram decimation factor
opts.histfil = 5; %Filter width for step histogram
opts.kdfmpp = .5; %Multiplier to kdf MinPeakProminence
opts.histfitx = [0 15]; %X range to fit histfit to
opts.rmburst = 0; %Remove bursts in kdfdwellfind
opts.verbose = 1; %Plot

%For each structure...


%Do kdfsfindV2 on it


%Verbose: To plot stepfinding or not [how to show without dwellfinding -- draw lines ? then that's just one line per]
% Maybe get an 'envelope' for each trace, and only draw the lines within that envelope. Would like for it to be one line, though

%Assemble to some unified output 