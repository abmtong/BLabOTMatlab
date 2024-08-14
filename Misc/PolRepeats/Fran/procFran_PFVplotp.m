function procFran_PFVplotp(pfv, pau, pauloc, nams)

%Plot PFV (k_n) vs k_p (pau duration) plots
% If we model each site with two exits: on-pathway incorporation (with rate k_n) and pausing (with rate k_p),
%  the pause efficiency 
%oh... pause efficiency, E, not pause duration, k_-p. 
% Well, the apparent pause duration is k_-p(1-E), so it's still okay
%  k_-p * (k_n / k_n + k_p) ~ k-p/(1+kp/kn)

%Number of pauses to look over
np = length(pauloc);

%Number of datasets
nn = length(nams);


%For every pause
for i = 1:np
    
    %For each dataset
    figure('Name', sprintf('Pause at %d', pauloc(i)))
    hold on
    for j = 1:nn
        %Scatter 1/k_n (PFV) vs. pause duration
        scatter( pfv{j}(1,:), pau{j}(i,:) )
    end
    set(gca, 'YScale', 'log')
    legend(nams)
    xlabel('PFV (bp/s)')
    ylabel('Pause duration (s)')
    
end