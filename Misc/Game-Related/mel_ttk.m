function out = mel_ttk(ehp, hit, spec)

%Simulates avg number of hits
%Inputs: enemy hp, hit [chance, maxhit], special [chance, dmg]

n=1e6; %simulate 1e4 kills
out = zeros(1,n);
if nargin < 1
    ehp = 750;
end

if nargin < 2 || isempty(hit)
    hit = [.8 800]; %chance to hit, max hit
end

if nargin < 2 || isempty(spec)
    spec = [0.4 1400]; %chance, hit. Only for 'easy' specials [single hits that deal fixed dmg]
end

for i = 1:n
    %Reset counters
    nh = 0;
    hp = ehp;
    while true
        %Do damage
        if rand < spec(1) %Roll for special
            hp = hp - spec(2);
        else
            if rand < hit(1) %Roll for hit
                hp = hp - rand * hit(2);
            end
        end
        
        %Increment counter
        nh = nh + 1;
        
        %Check for death
        if hp <= 0
            break
        end
    end
    out(i) = nh;
end


%Time to kill = n hits * time per hit + respawn time (3s)