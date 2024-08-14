function out = RPpass_p2_tpmeth(inst, inOpts)
%Let's try a TP-like approach to finding excursions from U

%Let's call an excursion going below x1 and then returning back above x2
% Choose x1 ~ below noise of U
% Choose x2 ~ center of the well

opts.fil = 10; %Filter amount
opts.kdfsd = 0.5; %Pick so that U and F are smooth, single peaks

if nargin > 1
    opts = handleOpts(opts, inOpts);
end

%So maybe... do kdf, findpeaks to estimate sd, then do like sigma=3 or 4

for i = 1:length(inst)
    con = inst.conpro;
    conF = windowFilter(@median, con, opts.fil, 1);
    
    %Find the U well
    [ky, kx] = kdf(conF, 0.1, opts.kdfsd);
    [pkht, pkloc, pkwid] = findpeaks(ky, kx);
    [~, si] = sort(pkht, 'descend');
    pkloc = pkloc(si);
    pkwid = pkwid(si);
    % Take the highest 2 peaks = F and U
    [x2, maxi] = max(pkloc(1:2));
    x1 = x2 - 2*pkwid(maxi); %pkwid is FWHM, which is ~sd*2, so take 3 or 4* SD below
    
    [inda, meaa] = tra2ind(conF > x1);
    [indb, meab] = tra2ind(conF > x2);
    
    %Find crossings below x1: diff(meaa) = -1
    kia = find(diff(meaa) == -1)+1; %Add 1 to convert to ind where it crosses
    %And crossings above x2: diff(meab) = 1
    kib = find(diff(meab) == 1)+1; %Add 1 to put this at the ind where it crosses
    
    %And match each crossing below to a crossing above
    hei = length(kia);
    tmp = zeros(hei, 4);
    curpos = 0; %Current position in the trace
    curind = 1; %Current index of tmp (transition #)
    while true
        %Find the next kia
        st = inda( kia( find(inda(kia)>curpos, 1, 'first') ) );
        if isempty(st)
            %No more inda's, end
            break
        end
        %Find the next kib
        en = indb( kib( find( indb(kib) > st , 1, 'first') ) );
        %Maybe this is an edge and it never comes back up: end early
        if isempty(en)
            break
        end
        
        %Add to data
        mid = round( (st + en)/2 ) ;
        tmp(curind,:) = [mid st en 1]; %Classify all of these as complete events
        
        %Update counters
        curind = curind + 1;
        curpos = en+1;
    end
    inst(i).rips = tmp( 1:curind-1 , :);
    
    
    %Call this the same 'rips' field to use in p3
    
end
out = inst;