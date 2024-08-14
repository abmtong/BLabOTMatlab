function ezPlotOmarRTH(inst, cropstr, rAopts)

if nargin < 3
    rAopts.per = 68; %68 for Mtb ruler, 239 for Eco ruler
    rAopts.nrep = 8;
    rAopts.pauloc = 58;
end

if nargin < 2
    cropstr = '';
end

fil = 10;
Fs = 1000;
onlycross = 00;

%Grab parts from rAopts
nrep = rAopts.nrep;
per = rAopts.per;
pauloc = rAopts.pauloc;



len = length(inst);
figure Name ezPlotOmarRTH
hold on
out = cell(1,len);
n = zeros(1,len);
for i = 1:len
    st = inst(i);
    hei = length(st.drA);
    
    tmp = cell(1,hei);
    for j = 1:hei
        dat = st.drA{j};
        
        %Filter
        datF = windowFilter(@median, dat, fil, 1);
        
        %Crop, if asked
        if ~isempty(cropstr)
            if ~isempty(st.(cropstr){j})
                datF = datF(st.(cropstr){j}(1):st.(cropstr){j}(2));
            else
                continue
            end
        end
        
        %Create RTH
        [~, hx, ~, hp] = nhistc(datF, 1);
        
        %Crop to repeats region
        ki = find(hx >= 0 & hx < per*nrep);
        hp = hp(ki);
        
        %Ignore if empty -- never entered ruler
        if isempty(hp)
            continue
        end
        
        %Only take crossers if asked
        if onlycross
            if hx(end) < per * nrep - 1
                %Not crossed
                continue
            end
        end
        
        n(i) = n(i) + 1;
%         hp = hp(ki);
%         hx = hx(ki); %#ok<NASGU>
        
        %Lengthen to 8x per, if needed. Because of binning, first pt will be 0.5, so you need to fill the left by floor(x) pts and the right to the end
        hp = [ nan(1, floor( hx(ki(1))) ) hp];
        hp = [hp nan(1,per*nrep - length(hp))];
        
        %Convert to time
        hp = hp / Fs;
        
        tmp{j} = hp;
    end
    %Concatenate, reshape, and take median
    tmp = [tmp{:}];
    tmp = reshape(tmp, per, []);
    tmp = median(tmp, 2, 'omitnan');
    plot((0:per-1), tmp);
    out{i} = tmp;
end

%Add pause location guidelines (dotted black)
yl = ylim;
for i = 1:length(pauloc)
    plot(pauloc(i) * [1 1], yl, 'k--')
end


lgn = cellfun(@(x,y) sprintf('%s, N=%d', x, y), {inst.nam}, num2cell(n), 'Un', 0);

legend(lgn)

xlim([0 per-1])
xlabel('Position (bp)')
ylabel('Dwell Time (s)')

