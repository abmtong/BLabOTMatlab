function out = bin2dec(instr)
%takes an input string/number 01010101 and outputs the decimal value

if ~ischar(instr)
    instr = num2str(instr);
end

instr = fliplr(instr);
len = length(instr);
twos = 2.^(0:len-1);
out = (instr == '1') * twos';