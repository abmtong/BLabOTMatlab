function RP_hmm_check(inst)
%Plots some stats from RP_hmm


mdls = [inst.hmm];
ns = mdls(1).ns;

%Mu
figure Name HmmMu, plot(reshape([mdls.mu],4,[])');
legend( arrayfun(@(x) sprintf( 'State %d', x), 1:ns, 'Un', 0) );

%Sig
figure Name HmmSig, plot(reshape([mdls.sig],4,[])');
legend( arrayfun(@(x) sprintf( 'State %d', x), 1:ns, 'Un', 0) );

%Diag(a) ~= 1/lifetime of each state
tmp = arrayfun(@(x) diag(x.a), mdls, 'Un', 0);
figure Name HmmLifetime, plot(reshape([tmp{:}],4,[])');
legend( arrayfun(@(x) sprintf( 'State %d', x), 1:ns, 'Un', 0) );

% %
% figure Name HmmSig, plot(reshape([mdls.sig],4,[])');
% legend( arrayfun(@(x) sprintf( 'State %s', x), 1:ns, 'Un', 0) );