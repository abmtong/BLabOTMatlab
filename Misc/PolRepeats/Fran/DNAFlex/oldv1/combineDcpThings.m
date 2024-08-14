function out = combineDcpThings(in)
%Just this once, need to merge hg1 and save it

%input: nx4 cell, made by [hg1p1; hg1p2; hg1p3; ...]


nkeep = 250e3; %Seqs to keep
nwid = 301; %bp per seq

%Ingest, reshape to nwid x N, pick up to nkeep (randomly)

out = cell(1,4);
for i = 1:4
    %Ingest
    tmp = [in{:,i}];

    %Reshape
    tmp = reshape(tmp, nwid, []);
    
    %Pick random
    nn = size(tmp, 2);
    if nn > nkeep
        tmp = tmp(:, randperm(nn, nkeep));
    end
    
    out{i} = tmp(:)';
end