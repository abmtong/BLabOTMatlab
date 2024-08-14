function out = importCDD(incell, nrow)
%Preps the data from the Conserved Domain Database (CDD) sequence alignment window for later use

%incell = copypaste of the CDD window into Matlab and format as cell array
% Paste with space delimiter
% First data row should have {'NAME' # 'Sequence' ...} (just going to use those first 3 cols)

%Strip 'Feature' rows, if they exist
ki = ~strncmp('Feature', incell(:,1),7);
incell = incell(ki,:);

%Calculate number of unique rows, if not supplied
if nargin < 2
    nrow = length(unique(incell(:,1)));
end

%Concatenate alignment text
for i = 1:nrow
    incell{i,3} = [incell{i:nrow:end,3}];
end

%Create output struct
% Struct with name, startres, and seq fields
out = struct('name', incell(1:nrow,1), 'startres', incell(1:nrow, 2), 'seq', incell(1:nrow, 3));


%Double-check that the seqs are the same length

assert( length( unique( cellfun(@length, {out.seq} ) ) ) == 1 , 'Output sequences are different length, check')




