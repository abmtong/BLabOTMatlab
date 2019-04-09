function out = hmmlo_postprocessV2(intr, goodsz)
%joins steps that HMM has cut in half
%requires preknowledge of the step size (e.g. from PWD)

if nargin < 2
    goodsz = 10;
end

%originally found steps
[oldin, oldme] = tra2ind(intr);
%fit HMM to the vitterbit fit but with sig = goodsz (so it should fit steps of size goodsz)
x = 0:0.1:15;
a = normpdf(x, 10, 2); %kinda cheating - I guess should mimic what the PWD suggests? FWHM?
a(1) = 1e3;
a=a/sum(a);
newh = findStepHMMV1b(intr, struct('sig', goodsz*2, 'a', a), 1);
[newin, newme] = tra2ind(newh.fit);

% [newin, newme] = AFindStepsV4(intr, 600);
%these indicies are the starts of the bursts
    function out = fni(x) %find nearest mean
        %could do this better, but should work for now
        [~, out] = min( abs( x - oldme ) );
    end
%so find nearest corresponding newme in oldme
keepind = arrayfun(@fni, newme);
len = length(keepind);
goodme = oldme(keepind);

newme2 = intr(newin);

%step sizes
ssz = diff(goodme);

%get dwell times
dwt = zeros(1,len);
doldin = diff(oldin);
for i = 1:len
    %get the dwell time
    ind = keepind(i);
    if ind == 1 %first dwell time is useless
        dwt(i) = -1;
    elseif i == len && ind == length(oldin)-1 %last dwell time is useless if it's also the last step
        dwt(i) = -2;
    else %otherwise dwell time is useful
        dwt(i) = doldin(i);
    end
end

%get burst times
but = zeros(1,len);

out.ssz0 = diff(oldme);
out.dwt0 = doldin;
out.but = but;

%use the new indicies to make the trace

len = length(newin)-1;
newmea = zeros(1,len);
newdwt = zeros(1,len);
newbut = zeros(1,len);
for i = 1:len
    stin = newin(i);
    enin = oldin(find(oldin > stin, 1 , 'first'));
    newmea(i) = median(intr(stin:enin)); %median the best for this? or just intr(stin)? it ~should~ transition on an exisiting transition
    newdwt(i) = enin-stin;
    newbut(i) = newin(i+1) - enin;
end

out.ssz = diff(newmea);
out.dwt = newdwt;
out.but = newbut;

figure, plot(intr, 'color', .7 * [1 1 1])
hold on
% plot(newh.fit+newmea(1), 'color', 'k')
plot(ind2tra(newin, newmea), 'g')
plot(ind2tra(newin, goodme)+newmea(1), 'r')
plot(ind2tra(newin, newme2), 'b')

end





