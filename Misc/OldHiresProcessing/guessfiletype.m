function outftype = guessfiletype(filesize)

if filesize == 2501936 %2444kb, current cal
    %= 42*8 + 625400*4 bytes
    outftype = 1;
elseif filesize ==  2401936 %2346kb, old cal
    %= 42*8 + 600400*4 bytes
    outftype = 2;
else
    outftype = 0; %regular data
end
        