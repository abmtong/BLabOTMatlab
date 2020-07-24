function cypher()
%cypher

% str1 = 'thswqd thz rbxp gwxp hg xl zwrnbrhk utpq wq kbqzbq,';
% str2 = 'w thz swrwgpz gtp iowgwrt xmrpmx hqz xhzp rphoft';
% str3 = 'hxbqd gtp ibbvr hqz xhnr wq gtp kwiohol opdhozwqd';
% str4 = 'gohqrlkshqwh; wg thz rgomfv xp gthg rbxp abopvqbukpzdp';
% str5 = 'ba gtp fbmqgol fbmkz thozkl ahwk gb thsp rbxp\n';
% str6 = 'wxnboghqfp wq zphkwqd uwgt h qbikpxhq ba gthg fbmqgol.';

str1 = 'lggk vhzxj rp vjjcevo ck zmx mgexo c scldgexjxs';
str2 = 'lgrx ivixjl ck zmx igdqxz gh zmx sjxll umcdm c mvs';
str3 = 'zvqxk hjgr pgbj ovwgjvzgjp. vz hcjlz c mvs';
str4 = 'kxnoxdzxs zmxr, wbz kgu zmvz c uvl vwox zg sxdcimxj';
str5 = 'zmx dmvjvdzxjl ck umcdm zmxp uxjx ujczzxk, c';
str6 = 'wxnvk zg lzbsp zmxr uczm scocnxkdx';


dict =  'abcdefghijklmnopqrstuvwxyz';
%t1  = 'aOcGefThijklmnoEqSstuvwxyD';
tran2=  'aUICVfOFPRNSHGLYKMDtWABEyT';

    function in = tlate(in, d, tr)
        for ii = 1:length(d);
            in(in==d(ii)) = tr(ii);
        end
    end

    function out = count(in, d)
        out = zeros(1,length(d));
        for ii = 1:length(d)
            out(ii) = sum(in == d(ii));
        end
    end

% figure
% frq = count([str1 str2 str3 str4 str5 str6], dict);
% [frq, ind] = sort(frq);
% dictfrq = dict(ind);
% plot(frq)
% arrayfun(@text, 1:26, frq, dictfrq)
% 
% letfreq = [.1 .1 .2 .2 .5 .9 1.6 1.6 1.9 2 2.3 2.3 2.3 3.1 3.2 3.7 4.0 5.1 6 6.6 7.2 7.2 7.9 8.1 9.6 12.3];
% letnms = 'zjxqkvgbywmfpucdlhrsinoate';
% hold on
% relfrq = letfreq * sum(frq) / 100;
% plot(relfrq)
% arrayfun(@text, 1:26, relfrq, letnms)


fprintf('%s\n',tlate(str1, dict, tran2))
fprintf('%s\n',tlate(str2, dict, tran2))
fprintf('%s\n',tlate(str3, dict, tran2))
fprintf('%s\n',tlate(str4, dict, tran2))
fprintf('%s\n',tlate(str5, dict, tran2))
fprintf('%s\n',tlate(str6, dict, tran2))


end