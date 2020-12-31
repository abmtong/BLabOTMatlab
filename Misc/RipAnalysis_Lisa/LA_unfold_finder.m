function rip_data = LA_unfold_finder()

% this function takes in a pulling file and finds unfolding transitions,
% the forces, the extension, and the contour length (see initialization).
% The returned variable is a cell of cells of arrays. Outer cell = all
% data. Inner cell = file. Innermost array = pull.

% Call it like: rip_data{file#}{pull#} = [index force extension contour];

% Be sure to run CK_FindRampBoundariesMini before running code. It should
% work with either a mini or hi-res file. (See variables to change below).
% Also dependent on XWLCContour.m, FilterAndDecimate.m, and
% CK_FindRampCycles.m

% Perhaps need to play with the threshold of standard deviation. 

% I should have written a "rip finder" code then written a separate script
% which split the data and then calls the rip finder code twice, once for
% high force and once for low. This is repetitive and not modular :(.
% However I do treat high and low a little different, so there's that.

% see end for info about code

% Lisa, January 13, 2016

%initialize variables.     
P = 0.65; %persistence length of polypeptide in nm (see Bustamante, , )
S = inf; % to use regular old WLC instead of XWLC
CL = 0.36; % contour length of a polypeptide, nm per aa.
high_force = 5.0; % 3.0; % defines high vs. low force (use a different standard 
% deviation in the two regions due to low force noise) (more pronounced in
% minis)

% **************** these variables must be changed for mini vs hi-res data!

linewindow = 200; %the size of the window that is fit to a line for the rip; 200 for hi-res, 50 or so for minis
filter_wnd =20; %use 5 or 10 for minis, 20 or more for hi-res
pool = 20; % if there are two transitions "pool" points apart, they are 
% combined (pooled) into one transition. May need to change for mini vs hi
% res due to correlation time? May also need to change for constructs which
% are more reversible (have more transitions back to back)
limit_hi = 3.5; %factor multiplied by sigma to find changes in force not within variation (i.e. rips)
% can use much higher limit on hi res due to higher trap stiffness (i.e. 3-4 vs 2.5).
limit_low =3.5; % can use 3.5 hi, 2 on minis?

disp('Select data file(s)...')
[dfile,dpath] = uigetfile('/Users/Lisa/Desktop/Analysis/*.mat', 'MultiSelect','on');
if ~iscell(dfile)
    dfile={dfile};
end

rip_data = cell(numel(dfile), 1);

%% Load the data
for k = 1:numel(dfile);
    disp(['Processing ' dfile{k}]);
    load([dpath dfile{k}]);

    %% for mini or hi-res data
    
    F = pdata.Y_force;
    x = pdata.A_distY;
    t = pdata.Time;
% this is the filtering Dan did but we are using our own.    
%     x = filtfilt(ones(filter_wnd,1)/filter_wnd, 1, x);
%     F = filtfilt(ones(filter_wnd,1)/filter_wnd, 1, F);
%     t = filtfilt(ones(filter_wnd,1)/filter_wnd, 1, t);
%     x = x(1:filter_wnd:end);
%     F = F(1:filter_wnd:end);
%     t = t(1:filter_wnd:end);

    % Split the data into pulling cycles       
    [RLegs,ULegs] = CK_FindRampCycles(t,x,1000,pdata.RampBoundaries); 
    
    RLegs = round(RLegs);
    ULegs = round(ULegs);
    
    rips = cell(numel(ULegs(:, 1)), 1);
    
    %% for fleezers files instead:
%     linewindow = 50; %the size of the window that is fit to a line for the rip; 200 for hi-res, 50 or so for minis
%     filter_wnd = 1;
%     [~,top] = max(trace.trap_sep); % take the pull, not the relax.
%     
%     if trace.force(top)<5
%         [~, top] = max(trace.force);
%     end
%     %some of them break, in which case we don't want that part of the pull.
%     %so if it is a low force at the top of the pull, just use a shorter
%     %region.
%     
%     F = trace.force(1:top);
%     x = trace.dist(1:top);
%     t = trace.time(1:top);
%     
%     RLegs = [1, top]; %each fleezers file only has one pull
%     ULegs = [1, top];
    
    %% Unfolding analysis
    for i = 1:numel(ULegs(:,1));
        xu = x(ULegs(i,1):ULegs(i,2)); % distance, cropped to pull i
        fu = F(ULegs(i,1):ULegs(i,2)); % force, cropped to pull i.
        
        xu_filter = FilterAndDecimate(xu, filter_wnd);
        fu_filter = FilterAndDecimate(fu, filter_wnd);
        
        upper = find(fu_filter>high_force); %dividing data into high and low force
        if isempty(upper)
            continue % some pulls have only a few points bc CK's code is 
            % for mini data and sometimes gets confused on hi-res data, so just skip these.
        else
            upper = upper(1); %only care about the first one past the limit
        end
        
        %% find unfolding transitions
        % transitions are points in difference function that are past
        % standard deviation by factor limit_hi or limit_low
        
        %Do high force first
        high_xu_f = xu_filter(upper:end); %_f is for filtered, u is for unfolding.
        high_fu_f = fu_filter(upper:end);
        
        diff_hi = diff(high_fu_f);
        avg_hi = mean(diff_hi);
        std_hi = std(diff_hi);
        
        indH = find(diff_hi < avg_hi-limit_hi*std_hi); % indices that are past threshold
        
        % now low force
        low_xu_f = xu_filter(1:upper-1);
        low_fu_f = fu_filter(1:upper-1);
        
        diff_low = diff(low_fu_f);
        avg_low = mean(diff_low);
        std_low = std(diff_low);
        
        indL = find(diff_low < avg_low-limit_low*std_low); % indices that are past threshold
        
        %% combine points past threshold that are within pool points of each other
   
        % only take points that are > pool points apart (to avoid marking one
        % drop multiple times)
        keepersH = []; % the indices we want to keep, high force
        
        if length(indH) == 1;
            keepersH = indH;
        else
            diffindH = diff(indH);
            for j=1:length(indH)-1
                keepersH(1) = indH(1);
                if diffindH(j) > pool
                    keepersH =[keepersH indH(j+1)];
                end
            end
        end
                
        keepersL = []; % the indices we want to keep, low force
        
        if length(indL) == 1;
            keepersL = indL;
        else
            diffindL = diff(indL);
            for j=1:length(indL)-1
                keepersL(1) = indL(1);
                if diffindL(j)>pool
                    keepersL =[keepersL indL(j+1)];
                end
            end
        end
        
        %% find the real maximum in the data (vs max difference) and then the rip size
        indH=zeros(length(keepersH), 1); %saving our final indices again
        ripFH= zeros(length(keepersH), 1); %rip force, high force
        extH = zeros(length(keepersH), 1);
        count =1;
        for j=1:length(keepersH)
            if keepersH(j)-5<=0
                disp('rip is near the high force cut-off, was removed. Fix your code Lisa!')
                count = count+1;
            elseif keepersH(j)+5<=length(high_fu_f)
                [ripFH(j), indH(j)] = max(high_fu_f(keepersH(j)-5:keepersH(j)+5));
                indH(j) = indH(j)+keepersH(j)-6; %the above returns an index between 1 and 11 (6 is middle); need to readjust
                if length(high_xu_f)>=indH(j)+linewindow+pool
                    approxline = polyfit(high_xu_f(indH(j)+pool:indH(j)+linewindow+pool),...
                        high_fu_f(indH(j)+pool:indH(j)+linewindow+pool), 1);
                    extH(j) = (ripFH(j) - approxline(2))/approxline(1) - high_xu_f(indH(j));
                else
                    disp('rip is too close to end of file to accurately measure, rip was removed.')
                    %could also just go to the end instead +linewindow; still
                    %break in case there are 2? second would be even less
                    %accurate
                    indH= indH(1:j-1);
                    ripFH = ripFH(1:j-1);
                    extH=extH(1:j-1);
                    break; % because if this rip can't be measured, neither can j+1
                end
            else % this else is used if rip is within 5 of the end, rather 
                % than within window of the end. In either case, too short
                disp('rip is too close to end of file to accurately measure, rip was removed.')
                indH= indH(1:j-1);
                ripFH = ripFH(1:j-1);
                extH=extH(1:j-1);
                break; % because if this rip can't be measured, neither can j+1
            end
        end
        indH=indH(count:end); %removing early points flagged by if statement.
        ripFH=ripFH(count:end);
        extH=extH(count:end);
        
        
        indL=zeros(length(keepersL), 1); %saving our final indices again
        ripFL= zeros(length(keepersL), 1); %rip force, low force
        extL = zeros(length(keepersL), 1);
        count=1;
        for j=1:length(keepersL) 
            if keepersL(j)-5<=0 || keepersL(j)+5>length(low_fu_f) 
                disp('rip is too close to beginning of file to accurately measure, rip was removed')
                count = count+1;
            else
                [ripFL(j), indL(j)] = max(low_fu_f(keepersL(j)-5:keepersL(j)+5));
                indL(j) = indL(j)+keepersL(j)-6;
                approxline = polyfit(xu_filter(indL(j)+pool:indL(j)+linewindow+pool),...
                    fu_filter(indL(j)+pool:indL(j)+linewindow+pool), 1);
                %using xu_filter instead of low_xu_f in case the linewindow crosses low force boundary
                extL(j) = (ripFL(j) - approxline(2))/approxline(1) - xu_filter(indL(j));
            end
        end
        indL=indL(count:end); %removing early points flagged by if statement.
        ripFL=ripFL(count:end);
        extL=extL(count:end);
        
        contourH = extH./real(XWLCContour(ripFH, P, S));
        contourL = extL./real(XWLCContour(ripFL, P, S));
        
        %test values for checking assumptions
%         disp('0.65, WLC')
%         extH./real(XWLCContour(ripFH, 0.65, inf))
%         disp('0.5, WLC')
%         extH./real(XWLCContour(ripFH, 0.5, inf))
%         disp('0.6, 150')
%         extH./real(XWLCContour(ripFH, 0.6, 150))
%         disp('0.65, 520')
%         extH./real(XWLCContour(ripFH, 0.65, 520))
         
        rips{i} = [indL, ripFL, extL, contourL; indH+upper-1, ripFH, extH, contourH];
        %the final value, column of rip index, forces, ext, contour length
        
        % plot the points (for kicks)
        figure;
        a = subplot(2, 1, 1);
        plot(xu_filter, fu_filter)
        hold on
        if size(indL)>0
            plot(xu_filter(indL), fu_filter(indL), '.r', 'MarkerSize', 24)
            plot(xu_filter(indL)+extL, fu_filter(indL), 'or', 'MarkerSize', 10)
        end
        
        if size(indH)>0
            plot(xu_filter(upper+indH-1), fu_filter(upper+indH-1), '.k', 'MarkerSize', 24)
            plot(xu_filter(upper+indH-1)+extH, fu_filter(upper+indH-1), 'ok', 'MarkerSize', 10)
            %for some reason when do fleezers files need to do extH'
            %instead of extH??
        end
        
        b = subplot(2, 1, 2);
        plot(low_xu_f(1:end-1), diff_low)
        hold on
        set (refline(0, avg_low-limit_low*std_low), 'Color', 'r')
        plot(low_xu_f(indL), diff_low(indL), '.r', 'MarkerSize', 24);
        
        plot(high_xu_f(1:end-1), diff_hi)
        set (refline(0, avg_hi-limit_hi*std_hi), 'Color', 'k')
        plot(high_xu_f(indH), diff_hi(indH), '.k', 'MarkerSize', 24);
        
        linkaxes([a b], 'x')

%         plot force for debugging 
%         figure;
%         plot(fu_filter)   
          
            
    end
    rip_data{k} = rips;
end
end

% What the code does:
% 1. Splits pulls into unfolding and refolding legs (U vs R)
% 2. Splits an unfolding leg according to a force cutoff, low vs high force
% 3. Finds the difference between each force data point
% 4. computes the mean, std dev of the diff
% 5. finds points in the diff which are unusually low, signifying a drop. ...
%     If there are two drops close together is uses the initial force value.
% 6. uses that point as a starting point to find the true transition point, ...
%     defined as the max force before the transition.
% 7. uses that new point as the force. Moves ten points forward and takes a...
%     window of points, fits to a line, and finds the extension of the rip

%These are possible thoughts on expanding to refolding:
%
% 1. Need to find transitions away from other transitions so can estimate
% size.
%
% 2. Transitions are identified by peaks in the first derivative that are
% greater than 2.5 sigma at high force or 1.6 sigma at low force (default)
%