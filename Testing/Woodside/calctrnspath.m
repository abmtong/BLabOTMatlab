function out = calctrnspath( iny, ybdys )
%Does a Woodside-style analysis of 'transition paths', i.e. given any pt in iny, does it cross ybdys(1) or ybdys(2) first?

%What's the fastest way to do this?

%Algo 1:
% Get array of y outside ybdys, say = 1 if above ybdys(2) and = -1 if < ybdys(1)
% Then, all 0s -> find previous and next nonzero, that segment then gets assigned A>B or B>A or A>A or B>B
% If you want to be cute, do next - previous + equals(n,p) * sign(n), as this maps the above sequence to [2 -2 -1 1]

%Then, bin by y and calculate the P(path | y)

