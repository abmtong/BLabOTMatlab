function i = quickFind(inArray)
for i = 1:length(inArray)
    if inArray(i) == 1
        return
    end
end
i = 0;