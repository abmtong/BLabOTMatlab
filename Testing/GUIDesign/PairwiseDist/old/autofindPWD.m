function out =  autofindPWD(insd)

opt1 = 1; %use PWDPWD instead of PWD
opt2 = 1; %equally divide fcs instead of random search

n = length(insd.contour);

goodpeak = 2.5;
filwid = 10;
filwidpost = 5;
minran = 20; %bp
minpts = 200; %points
numsegs = 10; %# of random segments to try per fc
out = [];
pkintmin = 0;

numsplit = 4; %if opt2=1, number of equal time segments to split FC into

fprintf(   'Searching FCs:[')
fprintf(repmat('|',[1 n]))
fprintf(']\n              [')

for i = 1:n %loop over every FC
    %try PWDing random sections
    con = insd.contour{i};
    len = length(con);
    ran = range(con);
    %skip overly short sections
    if ran < minran || len < minpts
        continue
    end
    
    %pick randomly 10 segments and try PWDing them
    j = 1;
    
    if opt2
        ran = range(con);
        numsegs = max( 1, min( ceil(ran/(60)), 10 ));
%         fprintf('%d', numsegs);
    end
    
    while j <= numsegs
        if opt2
            inds = floor( (len-1) * [ j-1 j ] /numsegs)+1;
            concrop = con(inds(1):inds(2));
        else
            %pick a random interval
            inds = sort(randi(len,1,2));
            %check that it's long enough (in both directions)
            concrop = con(inds(1):inds(2));
            if range(concrop) < minran || diff(inds) < minpts
                continue
            end
        end
        %valid region, take pwd
        if opt1
            [~, ~, ~, pwdx, pwd] = sumPWDV1b(concrop,filwid,0.1,filwidpost); close(gcf);
        else
            [pwd, pwdx] =  sumPWDV1b(concrop,filwid,0.1,filwidpost); close(gcf);
        end
        %evaluate PWD based on peakiness
        %desired peak at x, so look for lo/hi/lo pt in [.2,.8] [.8, 1.2] [1.2 1.8]
        bdy1 = find(pwdx > .2 * goodpeak, 1, 'first');
        bdy2 = find(pwdx > .8 * goodpeak, 1, 'first');
        bdy3 = find(pwdx > 1.2 * goodpeak, 1, 'first');
        bdy4 = find(pwdx > 1.8 * goodpeak, 1, 'first');
        [minpre, minpreind] = min(pwd(bdy1:bdy2));
        %[maxpk, maxpkind] = max(pwd(bdy2:bdy3));
        [minpost, minpostind] = min(pwd(bdy3:bdy4));
        %integrate the peak in square-space to determine "peakiness"
        startind = minpreind + bdy1 -1;
        endind = minpostind + bdy3 - 1;
        peak = ( pwd(startind:endind) - linspace(minpre, minpost, endind-startind+1) );
        pkint = sum (sign(peak) .* peak.^2);
        os(j).x = pwdx; %#ok<*AGROW>
        os(j).y = pwd;
        os(j).con = concrop;
        os(j).time = insd.time{i}(inds);
        os(j).pkint = pkint;
        j = j + 1;
    end
    %Sort these by pkint
    [~, sortind] = sort([os.pkint]);
    os = os(sortind);
    %pick by pkint - i.e. while 
    keepos = os(1);
    timeinds = {os(1).time};
    os(1) = [];
    while ~isempty(os)
        %check if next is acceptable - i.e. is unique to the other fcs
        curtind = os(1).time;
        keep = 1;
        for k = 1:length(timeinds)
            %check for any overlap - if so, reject
            if timeinds{k}(1) < curtind(2) && timeinds{k}(2) > curtind(1)
                keep = 0;
                break
            end
        end
        if keep
            keepos = [keepos os(1)];
            timeinds = [timeinds {os(1).time}];
        else
            os(1) = [];
        end
    end
    %assign final fields
    for j = 1:length(keepos)
        if isfield(insd,'name')
            keepos(j).name = insd.name(find(insd.name=='\',1,'last')+1:end-4);
        else
            keepos(j).name = insd.file(1:end-4);
        end
    end
    out = [out keepos];
    fprintf('|')
end
fprintf(']\n')

%Sort these by pkint
[~, sortind] = sort([out.pkint]);
out = out(sortind);
pkints = [out.pkint];
out = out (pkints > pkintmin);
