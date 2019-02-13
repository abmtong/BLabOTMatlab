function out = processDatNormalize(in)
%Takes the output from processDatVarIn and normalizes the laser deflections
in.nay = in.ay ./ in.sa;
in.nby = in.by ./ in.sb;
in.nax = in.ax ./ in.sa;
in.nbx = in.bx ./ in.sb;

out = rmfield(in, {'ay','by','ax','bx','sa','sb'});