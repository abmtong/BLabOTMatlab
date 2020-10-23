function outstr = export2kintek( inx, iny, inerr )
%Outputs the [data block] of the KinTek Explorer file
%Usually found after 'Kin_fitspacePlotP2Fits' and is a block of doubles, LE
% An array of [XData YData YError], error is optional (look for 3F every 8 bytes, as it is the MSB of most doubles in that range)

%Should find a way to find the data offset [in the .mrc file] to do this automatically
%Data length seems to be offset -12 before start of data, as a uint (the LSB is at that offset, assuming LE uint)

%Input is list of inx, then iny, then inerr, dont know how multiple data works

%Concatenate inputs, also make sure x,y,err are equal lengths
outdata = [inx(:) iny(:) inerr(:)];
nn = numel(outdata);
outstr = char(1, nn*8*2);
for i = 1:nn;
    %Convert double to LE and then hex string
    outstr( (i-1)*16 + (1:16) ) = num2hex( swapbytes( outdata(i) ) ) ;
end

outstr = outstr';