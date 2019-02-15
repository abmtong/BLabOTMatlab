function outrgb = hex2col(rgbhex)

if length(rgbhex) ~= 6
    error('requires rrggbb hex')
end

outrgb = [hex2dec(rgbhex(1:2))/255 hex2dec(rgbhex(3:4))/255 hex2dec(rgbhex(5:6))/255];
