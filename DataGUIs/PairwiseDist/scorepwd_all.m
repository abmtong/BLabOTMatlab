function scorepwd_all()

cons = getFCs('2');
cons = cons(cellfun(@(x)~any(isnan(x)), cons));
len=length(cons);

pctile = 0.8;
outlen = 200;

pwds = cell(1,len);
scor = zeros(1,len);
for i = 1:len
    tmp = calcPWDV1b(windowFilter(@mean, cons{i}, 5, 1), .1);
    tmp = windowFilter(@mean, tmp, 2, 1);
    tmpln = length(tmp);
    if tmpln >= outlen
        pwds{i} = tmp(1:outlen);
    else
        pwds{i} = [tmp(:)' tmp(end) * ones(1,outlen - tmpln)];
    end
    scor(i) = scorepwd(pwds{i}/pwds{i}(1), 0.1, [2.2 2.8]);
end

ss = sort(scor);
cutoff = ss(round(len * pctile));

keep = scor > cutoff;
pwdall = zeros(1,outlen);
pwdtop = zeros(1,outlen);
for i = 1:len
    pwdall = pwdall + pwds{i}(:)';
    if keep(i)
        pwdtop = pwdtop + pwds{i}(:)';
    end
end
figure, plot(pwdall/pwdall(1)), hold on, plot(pwdtop/pwdtop(1))