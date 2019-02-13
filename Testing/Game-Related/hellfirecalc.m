function ngood = hellfirecalc()
aff = {'CHC' 1000; 'CHD' 1000; 'Soc' 1000; 'DMG' 1500; 'El%+' 250; 'El%-' 750; 'AD' 1000; 'CDR' 1000; 'RCR' 1000;...
       'AS' 1000; 'Vit' 10000; 'Lf%' 1000; 'Arm' 1000; 'AR' 1000; 'L/s' 1000; 'L/h' 1000};
n = 1e6;
%n = {n(noCHC) n(noCHD) n(noSoc) n(noEl%) n(all))
%listed in order of most needed > least needed
cfstr = {'Soc' 'CHD' 'CHC' 'El%+'};
ngood = zeros(1,length(cfstr)+1);
affs = {1,3};
for i = 1:n
   afftmp = aff;
   goodaff = zeros(1,length(cfstr));
   %pick affixes
   for j = 1:3
       %get total relative probability
       afftbl = cumsum([afftmp{:,2}]);
       %roll a number to determine which affix is chosen
       roll = randi(afftbl(end));
       ind = find(roll<=afftbl, 1);
       %assign that affix
       affs{j} = afftmp{ind,1};
       %remove from table (it can no longer be rolled)
       afftmp(ind,:) = [];
       goodaff = goodaff + strcmp(affs{j}, cfstr);
   end
   %evalate whether hellfire is good
   if sum(goodaff) == 3
       ngood(end) = ngood(end)+1;
   elseif sum(goodaff) == 2
       ind = find(goodaff == 0,1);
       ngood(ind) = ngood(ind) + 1;
   end
end