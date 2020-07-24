function [in, me, tr, pf] = kvpen(medsz, pfs, varargin)
%Does kv with varargin input with penalty factor pfs (array) aiming for average size
% Does so by going until the step median < mediansize

%CONSIDER INSTEAD just finding nsteps = range(x)/medsz ? 
% Seems to be essentially equivalent, and much faster to boot

narginchk(3,inf);

if isempty(medsz)
    medsz = sqrt(estimateNoise(varargin{1},[],2));
end

if isempty(pfs)
    pfs = single(1:10);
end

pfs = sort(pfs, 'descend');
for i = 1:length(pfs)
    pf = pfs(i);
    [in, me, tr] = AFindStepsV5(varargin{1}, pf, varargin{2:end});
    if medsz > median(-diff(me))
        break
    end
end