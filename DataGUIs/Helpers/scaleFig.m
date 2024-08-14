function  scaleFig(inax, axis, scl)

%Scales the data in a plot by some amount

%Make sure axis = x or y
switch axis
    case 'x'
        fn = 'XData';
    case 'y'
        fn = 'YData';
    otherwise
        error('Invalid axis %s, only x or y supported')
end

obs = get(inax, 'Children');

for i = 1:length(obs)
    try
        
        obs(i).(fn) = obs(i).(fn) * scl;
    catch
    end
end