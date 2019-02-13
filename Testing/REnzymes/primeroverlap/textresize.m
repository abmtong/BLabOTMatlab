function textresize()

figure name txtrsz

tx = text(0, .5, 'hello world');
ax = gca;

    function out = getscntsz()
        hAx = gca;
        out = hAx.Position(3);
    end

tx.FontSize = 40/getscntsz();



end