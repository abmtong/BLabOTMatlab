function weightpsf(mult)
%Takes a PSF (Protein Structure File) and multiplies weights by mult
%Seems to work!


if nargin < 1
    mult = 100; %Default: Multiply masses by 100 for '10x time resolution'
end

fwid = 7; %Field width of the mass field in the PSF file. Usually 7 chars (e.g. '1.00120')

%Get the file...
[f, p] = uigetfile('*.psf');

%Create output file, f_reweight
[~, f, e] = fileparts(f);
fout = [f '_reweight' e];
f = [f e];

%Load this guy as text
fin = fopen(fullfile(p, f));
%And create output file (w+ is write new file)
fout = fopen(fullfile(p, fout), 'w+');

%File structure:
%{
%d !NATOM
[Then atom inputs, which we want to edit]
$d !NBOND: bonds

Atom lines are
%d %s{chain name} %d %s{res name} %s{res atom name} %s{atom name} %f{charge} %f{mass} 0
(res atom name is CA/CB/etc. while atom name is like N3 (NH3 nitrogen), HP(Hydrogen, Proline),
  probably for the 
%}

out = cell(1,1e5); %Hold for output
ind = 1;

state = 0; %'state' is enum of pre-NATOM, during, post-NATOM region
mst = []; %Char index for mass value, start
men = []; %same but end. So str = fgetl(fid); mstr = str(mst:men); gives the mass string '1.23456'
while ~feof(fin)
    str = fgetl(fin);
    switch state
        case 0 %Read until NATOM
            if strfind(str, '!NATOM')
                state = 1;
            end
        case 1 %Rewrite atom fields
            %Check if this is the end of this section( blank line or '!NBOND')
            if isempty(str) || ~isempty(strfind(str, '!NBOND'))
                state = 2;
            else
                %Try scanning for an atom identifier
                % Alternatively, it's fixed-width, so could just hardcode indexes...
                % Maybe find it dynamically first, then save it
                if isempty(mst)
                    [ts, nz] = textscan(str, '%d %s %d %s %s %s %f %f %d');
                    if ts{9}==0 %Let's say if we read the final %d as 0 (it should always be 0)
                        %Let's find the last non-space char before the final char (0)
                        men = find( ~(str(1:nz-1) == ' '), 1, 'last');
                        mst = find( str(1:men) == ' ', 1, 'last')+1;
                        %Sanity check: field width
                        if (men-mst+1) ~= fwid 
                            warning('Field width not what expected: Altering field width')
                            fwid = men-mst+1;
                        end
                    end
                end
                %Extract the mass
                ms = str2double(str(mst:men));
                %Sanity check for mass value (say 0.5 to 100)
                if ms < 0.5 || ms > 100
                    warning('Weird mass (%0.3f) found, check', ms)
                end
                
                %Apply mass multiplier
                ms = ms * mult;
                
                %Rewrite with sprintf. Do fixed width by printing at least 6 decimals then cropping (is there a better way to do this?)
                newmstr = sprintf('%0.6f', ms); %Eh this might get messed up if fwid changes, it should be %0.{fwid-1}f
                newmstr = newmstr(1:fwid);
                
                %Replace str
                str(mst:men) = newmstr;
            end
        otherwise %We're done, do nothing
    
    end
    out{ind} = str;
    ind = ind + 1;
end
%Crop empty
out = out(1:ind-1);

%Write to file
cellfun(@(x) fprintf(fout, '%s\n', x), out);
fclose(fin);
fclose(fout);