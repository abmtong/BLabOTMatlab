function LumicksToAntonyMat()
%Given a lumicks file, can we re-write it as an Antony .mat? To be used with Antony's stuff
% (actually this should work with any phage-processed file)
% Saves as a Matlab 5.0 ('-v6') file, which is needed for the Python loaders
%Hm, still weird. Not sure why.

%An Antony trace has fields:
%trace [struct]:
%  time [1xn double]
%  dist [1xn double]
%  unit [string, 'nm']
%  force[1xn double]
%  path [string, path to .dat file]
%  trap_sep [1xn double]
%  info [struct]:
%    bunch of metadata, maybe useful ones .... none?


%%NEXT also make a link file automaker
%link file = folder with
%.env  and per-data .link files

%%And then wrap them up into one automated tool

[f, p] = uigetfile('*.mat', 'Mu', 'on');
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
     
     fn = fieldnames(sd);
     
     %Sanity check: only one fieldname
     assert(length(fn) == 1)
     
     %Check if ContourData or stepdata
     iscd = strcmp(fn{1}, 'ContourData');
     
     sd = sd.(fn{1});
     
     %Convert to time/dist/force/trap_sep [arrays]
     %Scalar fields unit, path, info [has a bunch of stuff, assumedly unnecessary?]
     %OK maybe field order matters too for reading?
     if iscd
         trace.time = double(sd.time);
         trace.dist = double(sd.extension);
%          trace.unit = 'nm';
         trace.force = double(sd.force);
         trace.path = sd.name;
%          trace.info = struct('garbage', 'data');
         fax = double(sd.forceAX);
         fbx = double(sd.forceBX);
     else
         trace.time = double([sd.time{:}]);
         trace.dist = double([sd.extension{:}]);
%          trace.unit = 'nm';
         trace.force= double([sd.force{:}]);
         trace.path = sd.name;
%          trace.info = struct('garbage', 'data');
         fax = double([sd.forceAX{:}]);
         fbx = double([sd.forceBX{:}]);
     end
     %Estimate trap sep from force and extension
     trace.trap_sep = trace.dist - fax/sd.cal.AX.k + fbx/sd.cal.BX.k;
     
     %Next in file would be fluorescence data, but I think we can leave that
     
     if ~exist(fullfile(p, 'AntonyMats'), 'dir')
         mkdir(fullfile(p, 'AntonyMats'))
     end
     %Save in subfolder
     save(fullfile(p, 'AntonyMats', f{i}), 'trace', '-v6')
     
 end
 
 
 
 
 
 
 
 
 
 
 
 
 
 
