function rawparse = parse14(infp)

if nargin < 1
    %Default parse folder
    [f, p] = uigetfile('C:\Users\Alexander Tong\AppData\Roaming\Advanced Combat Tracker\');
    if ~p
        return
    end
    infp = fullfile(p, f);
end

%Load the log

fid = fopen(infp);

while true
    %Get log line
    ll  = fgetl(fid);
    %Check if we've hit eof
    if ll == -1
        break
    end
    %Check if it's a useful thing
    

    
    %Sometimes, when skills are cast simultaneously, you might get two 'you cast' lines before two 'damage' lines.
    %  Assumedly these are in the same order, so we just need to make sure, when matching casts + damage, we find the NEXT and UNUSED dmg line


end