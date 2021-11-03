function out = writeFasta(name, seq)
%Writes a fasta with sequence seq
charwid = 99; %Whats the FASTA charwid?

%Probably like:
fid = fopen(sprintf('.\\%s.fasta', name), 'w');
fwrite(fid, sprintf('%s\n', name));

len = length(seq);
st = 1;
en = st + charwid - 1;
while true
    if en > len
        fwrite(fid, seq(st:end))
        break
    else
        fwrite(fid, seq(st:en));
        st = en + 1;
        en = st + charwid - 1;
    end
end

fclose(fid);
