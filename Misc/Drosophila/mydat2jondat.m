function out = mydat2jondat(inst)
%Converts analyzed data with my method to a struct that Jonathan's programs use

%For each array in inst...
len = length(inst);
out1 = cell(1,len);
for i = 1:len
    tmp = inst(i);
    
    %For each nc...
    nnc = length(tmp.fr);
    out2 = cell(1,nnc);
    for j = 1:nnc
        tmpdat = tmp.fitRise{j};
        nnuc = length(tmpdat);
        
        outtmp = cell(1, nnuc);
        %For each spot...
        for k = 1:nnuc
            outtmp{k} = struct( 'time', (1:length(tmpdat(k).vals1) )/4  , 'MS2', tmpdat(k).vals2, 'PP7', tmpdat(k).vals1, 'name', [k 14-j+nnc]  );
        end
        
        out2{j} = [outtmp{:}];
    end
    out1{i} = out2;
end

%And collapse
out = [out1{:}];

%output is struct with fiels time, MS2, PP7, name (arbitrary; theirs is [nuc# nc#])

% out.time = []; %minutes, so fr/4 ; this uses 'real time' : is there a way to get this? img metadata? scan metadata.
% out.MS2 = []; %Red, ch2
% out.PP7 = []; %Green, ch1
% out.name = []; %[nuc#, nc#] but can be whatever. I'll keep as 1x2, just [index, nc]

