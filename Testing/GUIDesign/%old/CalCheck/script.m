figure, hold on

calsfl = {'flDk' 'flLa'}; 
decsfl = {'AX' 'AY' 'AS' 'BS'};

%un-normalize AX and AY
for i = 1:2
    for j = 1:4
        eval( sprintf( '[~, ~, %s%sP, %s%sF] = powspec(%s.%s, %s, [1 5 25, 125], 4, ''%s'');', calsfl{i}, decsfl{j}, calsfl{i}, decsfl{j}, calsfl{i}, decsfl{j}, '200e3/3',[calsfl{i} decsfl{j}]));
        eval( sprintf( 'text(%s%sF(end), mean(%s%sP(end-1e3:end)), ''%s'');', calsfl{i}, decsfl{j}, calsfl{i}, decsfl{j},[calsfl{i} decsfl{j}]));
    end
end



calshi = {'hiDk' 'hiLa'};
decshi = {'AX' 'AY' 'SA' 'SB'};

for i = 1:2
    for j = 1:4
        eval( sprintf( '[~, ~, %s%sP, %s%sF] = powspec(%s.%s, %s, [1 5 25, 125], 4, ''%s'');', calshi{i}, decshi{j}, calshi{i}, decshi{j}, calshi{i}, decshi{j}, '62.5e3',[calshi{i} decshi{j}]));
        eval( sprintf( 'text(%s%sF(end), mean(%s%sP(end-1e3:end)), ''%s'');', calshi{i}, decshi{j}, calshi{i}, decshi{j},[calshi{i} decshi{j}]));
    end
end

set(gca,'XScale','log','YScale','log')
legend('-dynamiclegend')