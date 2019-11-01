function out = getprot_steve()
%Taken from @avgprots

[f, p] = uigetfile('*.mat', 'Mu', 'on');
if ~p
    return
end

if ~iscell(f)
    f = {f};
end

len = length(f);
praws = cell(1,len);
prawunf = cell(1,len);
for i = 1:len
    %Load file
    eld = load([p f{i}]);
    eld = eld.eldata;
    
    %Extract protocol data
    pr = eld.prot;
    prw = lvprot(pr(:,1),pr(:,2));
    praws{i} = prw;
    prawunf{i} = pr;
end

out.prot = prawunf;
out.protinterp = praws;