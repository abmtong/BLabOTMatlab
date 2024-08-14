function out = enzeHeatMap(inst)
%Input: data struct for one cell, after fitRise

%Just take the first data. If more, run arrayfun(@this, inst)
if length(inst) > 1
    inst = inst(1);
end

frs = inst.fitRise;
nnc = length(frs);
lens = cellfun(@length, frs);
outraw = cell(1,nnc);

%Assemble as cell of (x,y,c1,c2) data (time, AP, red, green)
for i = 1:nnc
    fr = frs{i};
    tmp = cell(1, lens(i));
    tim = [inst.FrameInfo.Time]; %Real time, sec
    
    %Assume that pt 1 is fr(1) - 10, the default in FitRise. will need to be checked.
    timst = max(inst.fr{i}(1)-10 - 10, 1);
    
    for j = 1:lens(i)
        datlen = length(fr(j).vals1);
        timcrp = tim( timst + (1:datlen)-1 );
        
        %[ time ap grn red ]
        tmp{j} = [ timcrp(:)  fr(j).cenapdv(1) * ones( datlen ,1) fr(j).vals1(:) fr(j).vals2(:) ];
        
    end
    outraw{i} = tmp;
end

out = [outraw{:}];
len = length(out);
figure('Name', sprintf('%s, Green', inst.nam)), hold on
for i = 1:len
%     plot3(out{i}(:,1), out{i}(:,2), out{i}(:,3))
    surface( [out{i}(:,1) out{i}(:,1)], [out{i}(:,2) out{i}(:,2)], zeros(size(out{i}, 1), 2) ,[out{i}(:,3) out{i}(:,3)], 'EdgeColor', 'interp' )
    colorbar
    colormap jet
    xlabel('Time (s)')
    ylabel('AP position')
end

figure('Name', sprintf('%s, Red', inst.nam)), hold on
for i = 1:len
%     plot3(out{i}(:,1), out{i}(:,2), out{i}(:,4))
surface( [out{i}(:,1) out{i}(:,1)], [out{i}(:,2) out{i}(:,2)], zeros(size(out{i}, 1), 2) ,[out{i}(:,4) out{i}(:,4)], 'EdgeColor', 'interp' )
 colorbar
    colormap jet
    xlabel('Time (s)')
    ylabel('AP position')
end



