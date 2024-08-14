function out = prepREMDfiles(inp, outp, seqs)
%Prepares REMD simulation files
% inp: Source of Amber scripts/files
% outp: Folder to write to
% seqs: Sequences to set up, as struct with fields nam, seq (folder name; sequence)

%Basically, creates folders for REMD and creates a script to run them all
%Matlab fprintf \n should be Unix newline characters

len = length(seqs);

%Name constants
leapin = '99_leap.in'; %Filename of leap.in
leapseq = 'm = sequence {'; %Start of the leap file line
leapstr = 'm = sequence { ACE %s NHE }\n'; %String for sprintf
leapstrpos = 'addIons m Na+ %d\n'; %String for adding Na+
leapstrneg = 'addIons m Cl- %d\n'; %String for adding Cl-
runscript = '0_runall.sh';


%Read LEaP file
fid = fopen( fullfile(inp, leapin) );
leaplns = textscan(fid, '%s', 'Delimiter', '\n');
leaplns = leaplns{1};
nleap = length(leaplns);
%Find the line that has sequence
leapind = find( strncmp( leaplns, leapseq, length(leapseq) ), 1, 'first');
if isempty(leapind)
    error('LEaP sequence line not found, exiting')
end
fclose(fid);

% folnams = cell(1,len);
for i = 1:len
%     %Create folder name
%     folnam = fullfile(outp, seqs(i).nam);
    
    %Copy inp to a new outp 
    copyfile(inp, fullfile(outp, seqs(i).nam) ,'f');
    
    %Overwrite LEaP file
    fid = fopen( fullfile(outp, seqs(i).nam, leapin), 'w');
    for j = 1:nleap
        if j == leapind
            %Change the sequence in single letter to multi letter
            [aas, chr] = aa1to3(seqs(i).seq);
            
            %Write amino acid line
            fprintf(fid, leapstr, aas);
            
            %Add ions if necessary
            if chr > 0
                fprintf(fid, leapstrneg, abs(chr));
            elseif chr < 0
                fprintf(fid, leapstrpos, abs(chr));
            end
        else
            %Just print the same line as the original leap file
            fprintf(fid, '%s\n', leaplns{j});
        end
    end
    
    %Save folder name
%     folnams{i} = folnam;
end
fclose(fid);


%Create output script
out = fullfile(outp, 'runscript.sh');
fid = fopen( out, 'w' );
for i = 1:len
    %Maybe add an echo or something to mark the current job
    fprintf(fid, 'printf "\\n-----\\nRunning %s (job %d/%d)\\n-----\\n\\n"\n', seqs(i).nam, i, len);
    % Most of the time the window will be at the REMD input... can we put a msg there?
    %  Or just remove some of these output lines in the setup files to squish the output?
    %And run the ./[folder]/0_runremd.sh. 
    %To do so, we need to cd in and then un-cd in
    % Lets just do relative filenames so we don't have to translate Windows to WSL absolute paths
    fprintf(fid, 'cd ./%s/\n', seqs(i).nam );
    fprintf(fid, './%s\n', runscript );
    fprintf(fid, 'cd ..\n');
end
fclose(fid);




