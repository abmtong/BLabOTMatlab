function out = dsampph(in, dsampfact, type)
%downsamples an array of time points to an array of counts
%i.e. turns the [tick1 tick2 tick3 tick4...] APD data type into photon count
%seems like detection limit is about 5 ticks, or 125ns = 800MHz

if nargin < 2
    dsampfact = 40; %dsamp to 40 > 1MHz
end

if nargin < 3
    type = 'uint16'; %datatype, assume numbers won't go higher than intmax('uint16')
end

%fix if the tick count overflows the uint32 (period =  25ns*intmax('uint32') = 107s)
ind = find(diff(in) < 0);
if ind
    for i = 1:length(ind)
        in = uint64(in);
        in(ind(i)+1:end) = in(ind(i)+1:end) + uint64(intmax('uint32'));
    end
end

%renormalize in to [1, range(in)]
in = in - min(in) + 1;

len = floor(max(in) / dsampfact); %removes the final data pt if incomplete (not divisible)

convfnc = str2func(type);
out = convfnc(zeros(1, len));

for i = 1:length(in)
    ind = ceil( in(i) / dsampfact );
    if ind > len
        continue
    end
    out(ind) = out(ind) + 1;
end
end