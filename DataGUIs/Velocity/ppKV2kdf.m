function inst = ppKV2kdf(inst, varargin)
%Input: output of ppKV, varargin is same as kdfsfind's
%Output: Stepfinding replaced by kdfsfind

%Get bt and tl
bt = inst.bt;
tl = inst.tl;

haspre = isfield(bt, 'bupre');
if haspre
%Find corresponding tl for bupre/buposts *if the field exists
bufirst = cellfun(@(x) x(1)-x(2), {tl.mea});
bulast = cellfun(@(x) x(end-1)-x(end), {tl.mea});
preind = arrayfun(@(x) find(x == bulast), [bt.bupre] , 'Un', 0);
posind = arrayfun(@(x) find(x == bufirst), [bt.bupost], 'Un', 0);
%Sanity check lengths
assert(all(cellfun(@length, preind)==1))
assert(all(cellfun(@length, posind)==1))
end

%Do kdf sfinding. bt's need to be reversed.
[~, ~, ~, ~, btfit] = kdfsfind(cellfun(@(x)-x,{bt.tra}, 'Un', 0),varargin{:}); 
[~, ~, ~, ~, tlfit] = kdfsfind({tl.tra},varargin{:}); 
%Un-invert bt's
btfit = cellfun(@(x)-x, btfit, 'Un', 0);

%Replace ind, mea
[btind, btmea] = cellfun(@tra2ind, btfit, 'un', 0);
[tlind, tlmea] = cellfun(@tra2ind, tlfit, 'un', 0);

[inst.bt.ind] = deal(btind{:});
[inst.bt.mea] = deal(btmea{:});
[inst.tl.ind] = deal(tlind{:});
[inst.tl.mea] = deal(tlmea{:});

% for i= 1:length(bt)
%     inst.bt(i).ind = btind{i};
%     inst.bt(i).mea = btmea{i};
% end
% for i = 1:length(tl)
%     inst.tl(i).ind = tlind{i};
%     inst.tl(i).mea = tlmea{i};
% end

%Replace bupre, bupost
if haspre
    %Get new pre/post
    ki = cellfun(@length, {inst.tl.mea}) > 1;
    newbufirst = cellfun(@(x) x(1)-x(2), {inst.tl(ki).mea});
    newbulast = cellfun(@(x) x(end-1)-x(end), {inst.tl(ki).mea});
    nbf(ki) = newbufirst;
    nbl(ki) = newbulast;
    newpre = num2cell(nbl([preind{:}]));
    newpos = num2cell(nbf([posind{:}]));
    [inst.bt.bupre] = deal(newpre{:});
    [inst.bt.bupost] = deal(newpos{:});
    %And assign
%     for i = 1:length(bt)
%         inst.bt(i).bupre  = newbulast(preind{i});
%         inst.bt(i).bupost = newbufirst(posind{i});
%     end
end








