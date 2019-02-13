function out = testCmd(varargin)

if nargout == 0
fprintf( '%s', varargin{:});
else
    out = sprintf( '%s', varargin{:});
end