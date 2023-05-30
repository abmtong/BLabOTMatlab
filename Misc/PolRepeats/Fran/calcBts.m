function out = calcBts(dat, inOpts)
%Calcs backtrack amount and 'variance' for crossing traces


%plotNucHist opts, for determining 
opts.disp = [558 631 704]-16; %Location of lines
opts.shift = 558 - 16 - 1; %Shift x-axis

opts.fil = 100; %Filter half-width
opts.method = 1; %Method to create monotonic trace, see code

opts.minpause = 1; %Just set a simple pause duration. Could pol_dwelldist it, too maybe (low N though)
opts.Fs = 1e3;

% todo: handle struct

%todo: handle cell


len = length(dat);
trmono = cell(1,len);
for i = 1:len
    tr = dat{i};
    
    %Filter trace
    trF = windowFilter(@mean, tr, opts.fil, 1);
    
    %Crop to nuc region
    trF = trF( find(trF > opts.disp(1), 1, 'first') : find( trF > opts.disp(end), 1, 'first') );
    
    %If it doesn't cross, tr will be empty. Just ignore
    if isempty(trF)
        continue
    end
    
    %Create monotonic trace
    switch opts.method
        case 1 %Furthest extent, i.e. just round()
            trmono = round(trF);
            %Convert to monotonic
            trmono = makeMono(trmono);
        case 2 %Fit monotonic HMM
%             trmono = fitVitterbiV3(trmono);
            
    end
    
    %Post-processing: Combine multiple long pauses?
    
    %Convert staircase to staircase positions, heights
    [in, me] = tra2ind(trmono);
    %Difference in positions = dwell times
    dw = diff(in);
    
    %Set a simple pause detection routine
    tfpause = dw > opts.minpause;
    
    %Combine multiple adjacent pauses: first find adjacent pauses
    adjpau = strfind( double( tfpause ), [1 1] );
    %Then set the staircase heights to the same for adjacent pauses
    for j = 1:length(adjpau)
        me(j) = me(j+1);
    end
    %Re-convert to trace and back to merge the steps (2 steps at same height > 1 step)
    [in, me] = tra2ind( ind2tra( in, me ) );
    
    %Refind pauses
    dw = diff(in);
    tfpause = dw > opts.minpause;
    
    %Collect stats of each step
    hei = length(dw);
    outstd = zeros(1,hei); %std
    outran = zeros(1,hei); %range
    for j = 1:hei
        outstd(j) = std( tr( in(j):in(j+1)-1 ) );
        outran(j) = std( trF( in(j):in(j+1)-1 ) );
    end
    
    %Save output. Handle plotting in some other fcn?
    % What structure should we use?
    % a 1xn struct of each trace, with fields:
    % /monotonic trace (raw)
    % /mono trace (processed)
    % ind/mea/sd/range at each step
    
end







