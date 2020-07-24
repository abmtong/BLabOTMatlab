function out = dsampph(in, dsampfact, type)
%downsamples an array of time points to an array of counts
%i.e. turns the [tick1 tick2 tick3 tick4...] APD data type into photon count
%seems like detection limit is about 5 ticks, or 125ns = 800kHz on regular VI, I brought it down to 2 ticks = 5MHz
% This is slower than the APD dead time, also. Theoretically, rate should be n / (t - n*dt) where dt = dead time (50ns)
%JUST how should I assign the first timepoint? Error is O(1/photonrate), maybe insigificant
%The APD *should* be on if this data is taken, so you get at least the 200Hz dark noise

if nargin < 2
    dsampfact = 40e3; %dsamp to 40MHz > 1kHz
end

if nargin < 3
    type = 'uint16'; %datatype, assume numbers (photon counts) will be storable in type
end

%fix if the tick count overflows the uint32 (period =  25ns*intmax('uint32') = 107s)
ind = find(diff(in) < 0);
for i = 1:length(ind)
    in = uint64(in);
    in(ind(i)+1:end) = in(ind(i)+1:end) + uint64(intmax('uint32'));
end

%First photon is virtual, and is at time 0
in = in(2:end) - in(1);

%Calculate length of output
len = ceil(max(in) / dsampfact); %Last point will be cut short, w/e

%Sum with histcounts
out = histcounts(in, (0:len) * dsampfact);
convfnc = str2func(type);
out = convfnc(out);