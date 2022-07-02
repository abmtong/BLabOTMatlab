function procFran_pick(strnam, part)

if nargin < 1
    strnam = 'b';
end

if nargin < 2
    part = 1;
end

%If this is invoked as a command, str2double part
if ischar(part)
    part = str2double(part);
end

% strnam = 'd'; %Name of the struct in the workspace that has the data

%Part 1: pickbyeye everything
%Part 2: Assign to tfpick field
%Part 3: pickbyeye_rth things

len = evalin('base', sprintf('length(%s);', strnam));
switch part
    case 1
        %run pickbyeye on everything
        fprintf('Remember to clear tfpbe if you need to\n')
        for i = 1:len
            evalin('base', sprintf('pickbyeye(%s(%d).drA,%d)', strnam, i, i))
            evalin('base', sprintf('set(gcf, ''Name'',%s(%d).nam);', strnam, i))
        end
        fprintf('Remember to clear tfpbe if you need to\n')
    case 2
        %pickbyeye results stored in tfpbe cell, assign to field
        %Make sure pickbyeye has been run on everything
        tf = evalin('base', 'cellfun(@isempty, tfpbe);');
        if any(tf)
            fprintf('Structs %s not picked, skipping\n', sprintf('%d, ', find(tf)))
        end
        for i = find(~tf)
            evalin('base', sprintf('%s(%d).tfpick = tfpbe{%d};', strnam, i, i))
        end
        %Alternately:
        %evalin('base', sprintf('[%s.tfpick] = deal(tfpbe{:})', strnam)
    case 3
        fprintf('Remember to clear tfpbe if you need to\n')
        for i = 1:len
            evalin('base', sprintf('pickbyeye_rth(%s(%d).drA,%d)', strnam, i, i))
            evalin('base', sprintf('set(gcf, ''Name'',%s(%d).nam);', strnam, i))
        end
        fprintf('Remember to clear tfpbe if you need to\n')
end