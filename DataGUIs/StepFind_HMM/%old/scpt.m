for i = 5:20
    eval(sprintf('bhmm%d = findStepHMMV1b(b, bhmm%d);', i+1, i))
    drawnow
end