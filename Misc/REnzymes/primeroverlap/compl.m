function out = compl(in)
%finds complementary strand of ATGCs

in(in == 'A') = 't';
in(in == 'T') = 'a';
in(in == 'C') = 'g';
in(in == 'G') = 'c';
out = fliplr(upper(in));