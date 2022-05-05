function ThesisExamples(figno)
%Code to go alongside my graduate thesis. Generates the figures used in the code-based chapters.

%Example scripts are labeled by their figure number, eg thesisExample4p1 = code for Figure 4.1
%Run startup (../startup.m) to set paths

%Functions should be mostly standalone, with options handled by an 'options struct'
%The start of a function will usually set defaults in a struct, where the passed inOpts struct can overwrite them
% For example:
%{
function out = foo(in, inOpts)

%Set defaults
opts.a = 40;
opts.Fs = 2500;
opts.param = {44 22};


if nargin > 1 %If inOpts is passed...
    opts = handleOpts(opts, inOpts); %@handleOpts overwrites fields opts with those passed in inOpts
end
%}
% A valid inOpts might be struct('Fs', 1e4); -- inOpts does not have to have all the default fields (unset will be defaults)
% I use this style for most of my code, so get used to it? It's like name-value pairs, except passed as struct(varargin) instead of varargin.