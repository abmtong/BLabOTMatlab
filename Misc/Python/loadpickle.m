function out = loadpickle(filename)
%Hmm doesn't work without a pickle def file

  if nargin < 1
      [f, p] = uigetfile('*.pkl');
      filename = fullfile(p,f);
  end
  
  fid = py.open(filename, 'rb');
  out = py.pickle.load(fid);
  
  return
  outname = [tempname() '.mat'];
  pyscript = ['import pickle;import sys;import scipy.io;file=open("' filename '", "rb");dat=pickle.load(file);file.close();scipy.io.savemat("' outname '.dat")'];
system(['C:\ProgramData\Anaconda2\python.exe -c "' pyscript '"']);
a = load(outname);
end