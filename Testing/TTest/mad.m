function out = mad(in)

out = median(abs(in-median(in)));

end

