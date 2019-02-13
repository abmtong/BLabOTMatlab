function [ output_args ] = guessDistribution(opt)
%Guesses a dist. of

switch opt
    case 1 %flat
        d = @(x) 1;
    case 2 %gauss.
        d = @(x,sd) exp( (x.^2)/2/sd );
    otherwise
        error('Not a valid distribution option')
end

x = 



end

