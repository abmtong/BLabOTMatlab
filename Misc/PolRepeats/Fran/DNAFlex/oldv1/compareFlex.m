function out = compareFlex(dat)



nbp = 301;

%Be at least as flexible as 601 in left arm, at least as stiff as right arm

up1 = [-48 0.63941]; %Flexibility of left arm of 601
lo1 = [ 48 0.025708]; %Flexibility of right arm of 601


out = zeros(3,4);
for i = 1:4
    %Concatenate (if necessary) and reshape
    tmp = reshape([dat{:,i}], nbp, []);
    xx = -(nbp-1)/2 : (nbp-1)/2 ;
    
    %Count how many are higher than up1(2) at x==up1(1) and lower than lo1, or reverse
    ki = tmp( xx == up1(1), : ) >= up1(2) & tmp( xx == lo1(1), : ) <= lo1(2);
    out(1,i) = sum( ki );
    
    ki = tmp( xx == -up1(1), : ) >= up1(2) & tmp( xx == -lo1(1), : ) <= lo1(2);
    out(2,i) = sum( ki );
    
    out(3,i) = size(tmp,2);
    
    



end




