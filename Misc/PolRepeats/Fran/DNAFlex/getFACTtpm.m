function [out, tpms] = getFACTtpm(infp)


if nargin < 1
    [f, p] = uigetfile('*.rsem');
    infp = fullfile(p,f);
end


%Search lines for the FACT subunits

fact = {'gene-SSRP1', 'gene-SUPT16H'};
ns = length(fact); %N subunits

%Take it as ... average TPM?

% Code taken from procRnaSeq
%Load file
fid = fopen(infp);
%Skip first line, which is column names
fgetl(fid);
tmp = textscan(fid, '%s %s %f %f %f %f %f', 'Delimiter', {'\t' '\n'});
fclose(fid);
gennam = tmp{1};
gentpm = tmp{6};

tpms = nan(1,ns);
%Find these subunits' TPMs
for i = 1:ns
    ki = find( strcmp(gennam, fact{i}), 1, 'first' );
    tpms(i) = gentpm(ki);
end

out = mean( tpms );