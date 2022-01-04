function out = KVCondp2(inst, inOpts)
%Input: output of KVCond: struct with fields con, ind, mea, tra, ...


%Dwell categorization
opts.minlen = 3; %minimum length of dwell, pts


%Peak fitting afterwards
opts.ngauss = 2;

if nargin > 1
    opts = handleOpts(opts, inOpts);
end


len = length(inst);
out = cell(1,len);
sts = cell(1,len);
%For each trace in inst...
for i = 1:len
    st = inst(i);
    %Categorize dwells as 'ok' if > opts.minlen
    dwlen = diff(st.ind);
    dwtf = dwlen > opts.minlen;
    
    %'ok' steps are then ones flanked by dwtf == 1
    sttf = dwtf(1:end-1) & dwtf(2:end);
    
    %Extract these 'ok' steps
    tmp = st.mea([false sttf]) - st.mea([sttf false]);
    
    %Add to data
    sts{i} = tmp;
    
    
    
    
    
end







