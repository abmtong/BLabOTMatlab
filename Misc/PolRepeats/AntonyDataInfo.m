%{
Gabizon  doi:10.1038/s41467-018-05344-9
(I've labeled it as 'Antony data' since I got it from him)

Info from paper (mostly Supp Info):
SF1a
Alignment procedure is "Maximize the probability of observing a [repeat length] given the others"
 My procedure is maximize the variance of a repeat
 A's removes the segment in question when considering its alignment to the rest

SF1e
 'Regularization' is their name for crossing-time analysis
  It corresponds to the choice of the backtracking parameter lambda (allow the trace to move backwards, but at a cost)
 They seem to have an 'objective' way to choose this parameter

Offset
 Looks like they did offset relative to each other, not offset relative to some 'truth' (i.e., dot each trace with each other)

Analyzing again
 Since the inital guesses are pretty rough, can redo the analysis using the first answer to better the guess

%}