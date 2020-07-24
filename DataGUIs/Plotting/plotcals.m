function plotcals()

[f, p] = uigetfile('phage*.mat', 'MultiSelect', 'on');

if ~p
    return
end

if ~iscell(f)
    f = {f};
end


len = length(f);

for i = len:-1:1
    load([p f{i}], 'stepdata');
    cals(i) = stepdata.cal;
end

%plot AXs
cax = [cals.AX];
cay = [cals.AY];
cbx = [cals.BX];
cby = [cals.BY];
figure, 
plot([cax.a], [cax.k], 'o');
hold on, plot([cay.a], [cay.k], 'o');
plot([cbx.a], [cbx.k], 'o');
plot([cby.a], [cby.k], 'o');

% figure, plot( 1./[cax.a].^1 ,[cax.a].^1 .* [cax.k])


