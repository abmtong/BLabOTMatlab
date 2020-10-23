function out = data2num(instr)


% fmt = 'single';
% nby = 4;

fmt = 'double';
nby = 8;

off = 0;

instr = instr(off+1:end);

len = length(instr);
nchar = nby*2;

out = zeros(1,floor(len/nchar));

for i = 0:length(out)-1
    switch fmt
        case 'double'
            out(i+1) = hex2num(instr( i * nchar + (1:nchar) ) );
        case 'single'
            out(i+1) = typecast(uint32(hex2dec(instr( i * nchar + (1:nchar) ))),'single');
    end
end

%

%For every 4? 8? bytes....


%Convert to single

