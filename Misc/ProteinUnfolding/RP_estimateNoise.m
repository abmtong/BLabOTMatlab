function [out, rawout] = RP_estimateNoise(inst, frng)
%Estimates noise of trace in frng

if nargin < 2
    frng = [20 25];
end


len = length(inst);
rawout = cell(1,len);
for i = 1:len
    tmp = inst(i);
    
    %Do in procon units
    % Ignore if empty
    if isempty(tmp.conpro)
        continue
    end
    
    %Get pull data, prerip
    fpull = tmp.frc(1:tmp.ripind);
    kif = find(fpull > frng(1), 1, 'first'): find(fpull < frng(2), 1, 'last');
    pcfol = tmp.conpro(kif);
    
    %Get retract data
    if isfield(tmp, 'refind') && ~isempty(tmp.refind)
        fret = tmp.frc(tmp.retind:tmp.refind);
    else
        fret = tmp.frc(tmp.retind:end);
    end
    kiu = find(fret < frng(2), 1, 'first'):find(fret > frng(1),1,'last');
    pcunf = tmp.conpro(tmp.retind:end);
    pcunf = pcunf(kiu);
    
    rawout{i} = [ std( pcfol ) std(pcunf) ];
    
end

rawout = reshape([rawout{:}], 2, [])';
out = median(rawout,1,'omitnan');

