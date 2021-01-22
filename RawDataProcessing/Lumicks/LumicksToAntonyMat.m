function out = LumicksToAntonyMat()
%Given a lumicks file, can we re-write it as Boltzmann .dats? To be used with Antony's stuff

%The .dat has {A,B} * {X Y S} and Trap Delta; can write others as zero

%%NEXT also make a link file automaker
%link file = folder with
%.env  and per-data .link files

%%And then wrap them up into one automated tool

[f, p] = uigetfile('*.mat');
 if ~p
     return
 end
 
 if ~iscell(f)
     f = {f};
 end
 
 len = length(f);
 
 for i = 1:len
     trace = [];
     %Load my file
     sd = load(fullfile(p,f{i}));
     
     fn = fieldnames(fn);
     
     %Sanity check: only one fieldname
     assert(length(fn) == 1)
     
     %Check if ContourData or stepdata
     iscd = strcmp(fn{1}, 'ContourData');
     
     sd = sd.fn{1};
     
     %Convert to time/dist/force/trap_sep [arrays]
     %Scalar fields unit, path, info [has a bunch of stuff, assumedly unnecessary?]
     if iscd
         trace.time = sd.time;
         trace.dist = sd.extension;
         trace.force = sd.force;
         trace.unit = 'nm';
     else
         trace.time = [sd.time{:}];
         trace.dist = [sd.extension{:}];
         trace.force= [sd.force{:}];
         trace.unit = 'bp';
     end
     %Hopefully trap_sep[], path aren't needed
     
     %Save in subfolder
     save(fullfile(p, 'AntonyMats', f{i}), 'trace')
     
 end
 
 
 
 
 
 
 
 
 
 
 
 
 
 