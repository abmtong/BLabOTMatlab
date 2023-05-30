function outraw = ezSum_batch_batch(dats, infos)

%Automator for ezSum_batch, haha
%Basically, lets you set up params for analysis of the entire dataset and does it

%dats: cell of data {a b c} where a = input to ezSum_batch
% infos: struct that basically tells the input to ezSum_crop and ezSum_batch. 

%infos has fields:
%{
ind : index of dats to use
nam : name to rename the cropped struct to
frng : frame range to crop to (cropEzDro)
r : radius for ezSum_batch
frch : frames for ezSum_batch
%}

%Look out for:
% Make sure frng is large enough for fitRise (could handle this , but eh)


len = length(infos);
outraw = cell(1,len);
for i = 1:length(infos)
    %Crop
    tmp = cropEzDro(dats{ infos(i).ind }, infos(i).frng );
    
    %Adjust frame range to 
    tmpfrch = infos(i).frch - infos(i).frng(1) + 1;
    
    %Run ezSum_batch
    tmp2 = ezSum_batchV2(tmp, tmpfrch , infos(i).r, 2, infos(i).nam );
    
    %Run fitRise
    tmp3 = fitRise(tmp2);
    
    %Save
    outraw{i} = tmp3;
end


%Plot rise times together
figure Name ezSBB
hold on
lgn = cell(1,len);
for i = 1:len
    %Get data
    tmp = [outraw{i}.dt];
    [p, x] = nhistc( tmp , 1 );
    plot(x,p)
    %Create legend entry with stats
    lgn{i} = sprintf('%s: Med:%0.2f, Mean: %0.2f', infos(i).nam, median(tmp, 'omitnan'), mean(tmp, 'omitnan'));
end
legend(lgn)





