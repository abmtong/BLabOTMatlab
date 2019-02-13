ln = fgetl(fid);
dates = [];
titles = [];
contents = [];
iscontent = 0;
tempcontent = '';
while ischar(ln)
    if iscontent
        tempcontent = [tempcontent '\n' ln]; %#ok<*AGROW>
        if regexp(ln, '</content:encoded>')
            iscontent = 0;
            contents = [contents {tempcontent}];
            tempcontent = '';
        end
    else
        if regexp(ln, '<title>')
            titles = [titles {ln}];
        elseif regexp(ln, '<wp:post_date>')
            dates = [dates {ln}];
        elseif regexp(ln, '<content:encoded>')
            if regexp(ln, '</content:encoded>')
                contents = [contents {ln}];
            else
                iscontent = 1;
                tempcontent = [tempcontent ln];
            end
        end
    end
    %look for special xml tags
    %{
    datestr
    <wp:post_date>2018-06-07 16:00:35</wp:post_date>
    
    title
    <title>The One with Joey’s Mom</title>
    
    contentstart
    <content:encoded><![CDATA[...
    
    content end
    ...]]></content:encoded>
    %}
    
    
    
    
    ln = fgetl(fid);
end

%do post processing