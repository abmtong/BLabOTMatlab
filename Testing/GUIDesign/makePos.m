%Finds all double arrays, saves another var. with negatives removed 

a = whos;
%Check for class 'double'
a = a(strcmp({a.class},'double'));
%Check for matrix
a = a(cellfun(@(x)any(x>1), {a.size}));
% @isscalar would work, too
a = {a.name};
for ai = 1:length(a)
    anam = a{ai};
    eval( sprintf( '%spos = %s(%s>0);', anam, anam, anam) )
end
clear a ai anam
clear *pospos