function out = opticalFilter(spec, varargin)


len = length(varargin);
for i = 1:len
    %Normalize
    varargin{i}(:,2) = varargin{i}(:,2)/max(varargin{i}(:,2));
    
    %Interp
    iy = interp1(varargin{i}(:,1), varargin{i}(:,2), spec(:,1) );
    
    %Apply
    spec(:,2) = spec(:,2) .* iy;
end

%Rescale output

% spec(:,2) = spec(:,2)/max(spec(:,2));

out = spec;