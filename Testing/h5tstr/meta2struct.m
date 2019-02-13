function out = meta2struct(instr)
%UNFINISHED n probably won't, too much to parse (cant find a good way to do so)

%Input is a Lumicks hdf5 "metadata" dataset, of form '{"field": [data1, data2], "field2": data3, "field3": "field3b": data4, etc.}
%Done by recursion
%Brackets[] = start cell array
%Curly braces = new struct field level

%format is { FN : DATA, where DATA can also be FN : DATA }

%Search over every colon
clns = find(instr == ':');

for i = 1:length(colons)
    %separate string before and after colon
    pre = instr(1:clns(i));
    post = instr(clns(i):end);
    %For every colon, there's:
    %Depth: How many fieldnames needed, noted by how many {'s there are before it, and the current fn
    brcs = [find(instr(1:clns(i)) == '{') clns(i)];
    brcs(1) = [];
    
    %get fieldnames
    fns = cell(1, length(brcs));
    for j = 2:length(brcs)
        fninds = find(pre(1:brcs(j)) == '"', 2, 'last');
        fns{j} = pre(fninds(1):fninds(2));
    end
    fns = cellfun(@formath5fn, fn);
    
    %Get data: Either one field (not delimited by { or [ ) or more complex
    if post(2) == '{'
        %if it starts with '{', do nothing: this is just a declaration of state
    elseif post(2) == '['
        
    else %just one data
        %find the following '[,}]' which denotes the end of the data
        daten = find(post == ',' || post == '}', 1);
        dat = eval(post(2:daten-1));
    end
end
    