function out = RPp5(inst, inOpts)
%Calculates work by method described in doi.org/10.1038/nature04061


opts.fil = 100; %Filter amount

% opts.xrng = [650 740]; %X-range, nm . Should do this programatically... F range?
opts.frng = [1 25]; %Force range. Or a rip detector?
opts.xtrim = [10 -5]; %Use force range to get ext range, trim this much from edge, nm
opts.ibinsz = 0.1; %Interp dx
opts.hbinsz = .1; %Final histogram bin size, pNnm
opts.hbinsd = [10 3]; %Final histogram sd for kdf for [unfolding, refolding]; pNnm

opts.sepbyfile = 0; %Separate by file?
opts.croprip = 1; %Crop to just rip area?

opts.debug = 1; %Debug plot everything

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


%First, separate by file
if opts.sepbyfile
    [u, ~, ic] = unique({inst.file});
else
    %Just act as if unique was all the same
    u = {'file'};
    ic = ones(1, length(inst));
end
% Maybe we dont have to separate by file anymore?

nfile = length(u);

out = cell(1,nfile);

for i = 1:nfile
    %Get the data from this file
    instcrp = inst( ic == i );
    
    %Extract data
    
    %Get range across all files
    
    %Debug plot
    if opts.debug
        figure
        hold on
        dx = 80; %Plot with X shifting
        xlabel('Extension (nm, rel.)')
        ylabel('Force (pN)')
        title('Raw data: pull, relaxation, XWLC stretching')
        
    end
    
    hei = length(instcrp);
    wrks = zeros(hei,3); %Folding, Unfolding, Stretching work
    for j = 1:hei
        tmp = instcrp(j);

        for k = 1:2 %Pull and retract
            if k == 1
                ki = 1:tmp.retind;
                %Apply force range: first crossing of frc1 to last crossing of frc2
%                 st = find( tmp.frc(ki) > opts.frng(1), 1, 'first');
%                 en = find( tmp.frc(ki) < opts.frng(2), 1, 'last' );
%                 ki = ki(st:en);
            else
                ki = tmp.retind:length(tmp.ext);
                %Apply force range: first crossing of frc2 to last crossing of frc1
%                 st = find( tmp.frc(ki) > opts.frng(2), 1, 'first');
%                 en = find( tmp.frc(ki) < opts.frng(1), 1, 'last' );
%                 ki = ki(st:en);
            end
            
            %Get pull/retract cycle
            ext = tmp.ext(ki);
            frc = tmp.frc(ki);
            
            
            %         %Retracting
            %         extr = tmp.ext(tmp.retind+1:end);
            %         frcr = tmp.frc(tmp.retind+1:end);
            %
            %Filter
            extf = windowFilter(@median, ext, opts.fil, 1);
            frcf = windowFilter(@median, frc, opts.fil, 1);
            %         extrf = windowFilter(@mean, extr, opts.fil, 1);
            %         frcrf = windowFilter(@mean, frcr, opts.fil, 1);
            
            %Apply force range to get ext range. Only for k==1, keep it the same for both
            if k == 1
                %First crossing of frc1 to last crossing of frc2
                st = find( frcf > opts.frng(1), 1, 'first');
                en = find( frcf < opts.frng(2), 1, 'last' );
%                 extfc = extf(st:en);
                xrng = [ext(st) ext(en)] + opts.xtrim;
%                 frcfc = frcf(st:en);
                %And take the x boundaries 
%             else
%                 %First crossing of frc2 to last crossing of frc1
%                 st = find( tmp.frc(ki) > opts.frng(2), 1, 'first');
%                 en = find( tmp.frc(ki) < opts.frng(1), 1, 'last' );
%                 extf = extf(st:en);
%                 frcf = frcf(st:en);
            end
            
%             %Create ext range. Only for k==1, keep it the same for both
%             if k == 1
%                 xrng = [ext(1) ext(end)] + opts.xtrim; %Trim some on each side
%             end
            
            %Set up interp: remove dupes with @unique, if any [just to prevent erroring]
            [extu, ue] = unique(extf);
            frcu = frcf(ue);
            %         [extfu, uer] = unique(extrf);
            %         frcfu = frcpf(uef);
            
            %And interp
            xxi = xrng(1):opts.ibinsz:xrng(2);
            yyi = interp1(extu, frcu, xxi, 'linear');
            %         yyi = interp1(extfu, frcfu, xxi, 'linear');
            
            %Crop to just the rip part: place one step 
            if opts.croprip
                
                
            end
            
            %Integral is just sum of yyi
            wrks(j,k) = sum(yyi) * opts.ibinsz;
            %         wrkf = sum(yyfi) * opts.ibinsz;
            
            if opts.debug
                plot(xxi + j*dx, yyi)
            end
            
            
        end
        
        %Calculate the energy for just stretching this polymer
        %Just take some large force range
        fpoly = linspace( opts.frng(1), opts.frng(2) , 1e3);
        %Calculate ext given the XWLC fit
        xpoly = XWLC(fpoly, tmp.xwlcft(1),  tmp.xwlcft(2)) *  tmp.xwlcft(3) + XWLC(fpoly, tmp.xwlcft(6),  inf) *  tmp.xwlcft(7); 
        
        %Restrict to x range by interp
        ypoly = interp1( xpoly, fpoly, xxi, 'linear' );
        
        if opts.debug
            plot(xxi + j*dx, ypoly)
        end
        
        %Integrate
        wrks(j,3) = sum(ypoly) * opts.ibinsz;
        
        %Subtract from work
        wrks(j,1:2) = wrks(j,1:2) - wrks(j,3);
    end
    
    %Plot output histogram
%     [p1,x1] = nhistc(wrks(:,1), opts.hbinsz);
%     [p2,x2] = nhistc(wrks(:,2), opts.hbinsz);

    %For lower N, maybe a kdf is easier to interpret
    %Lazy: Make a grid that contains both data
    [~, xx] = kdf( [wrks(:,1);wrks(:,2)], opts.hbinsz, max(opts.hbinsd));
    % And use this grid to calculate individual kdfs
    [p1,x1] = kdf(wrks(:,1), opts.hbinsz, opts.hbinsd(1), [xx(1) xx(end)]);
    % Maybe expand x1 here , since it will be the same grid for both guys.
    [p2,x2] = kdf(wrks(:,2), opts.hbinsz, opts.hbinsd(2), [xx(1) xx(end)]); %Make it on the same x-range
    %Normalize; kdf sums normalized gaussians, so just divide by N
    p1 = p1 / sum(~isnan(wrks(:,1)));
    p2 = p2 / sum(~isnan(wrks(:,2)));
    
    %And plot
    figure('Name', sprintf('RPp5 data %d', i))
    plot(x1,p1)
    hold on
    plot(x2,p2)
    
    xlabel('Energy(pNnm)')
    ylabel('Probability density')
    %The refolding work is so small, but I guess that's to be expected
    legend('Unfolding Energy', 'Refolding Energy')
    out{i} = wrks;
    
    %The intersect of the two curves should be the dG?
    % Check for intersection. If there's just one, label and mark energy
    % Set the same grid with @kdf so we can just subtract the two
    dy = p2 - p1; %Should be positive early, then negative
    %Find where it changes sign
    zpos = find( diff( sign(dy) ) );
    
    %For each hit in zpos, linearly interpolate to find the zero
    for j = 1:length(zpos)
        %That means at zpos(i), zpos(i)+1 the crossing happens
        ki = zpos(j) + [0 1];
        
        %And linearly interpolate to get the x, y position
        
        %x position is the ratio of the magnitude before/after the crossing
        tmp = abs( dy( ki ) );
        crdx = tmp(1) / sum(tmp); %pts
        crx = crdx * opts.hbinsz + xx( ki(1) ); %energy
        
        %Lets get the y position by interping across both graphs and taking the average
        cry1 = interp1([0 1], p1(ki), crdx, 'linear');
        cry2 = interp1([0 1], p2(ki), crdx, 'linear');
        cry = (cry1+ cry2)/2;
        
        %And plot
        scatter(crx, cry, '*', 'k')
        text(crx, cry, sprintf('  \\DeltaG: %0.3f pNnm', crx))
    end
    
end

%Save output


%Then we want to take the 'intersect' of the F and U distribution, and subtract the base XWLC energy for this range

% Maybe we can do the subtraction right now, as a function of extension range


