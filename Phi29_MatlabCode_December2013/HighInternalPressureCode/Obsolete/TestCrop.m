function [spatial_rect,h_image,placement_cancelled] = TestCrop(h)

spatial_rect = [];
h_image = imhandles(h);
if numel(h_image) > 1
    h_image = h_image(1);
end
hAx = ancestor(h_image,'axes');

if isempty(h_image)
    eid = sprintf('Images:%s:noImage',mfilename);
    msg = sprintf('%s expects a current figure containing an image.', ...
        upper(mfilename));
    error(eid,'%s',msg);
end

h_rect = iptui.imcropRect(hAx,[],h_image);
placement_cancelled = isempty(h_rect);
if placement_cancelled
    return;
end

spatial_rect = wait(h_rect);
if ~isempty(spatial_rect)
    % Slightly adjust spatial_rect so that we enclose appropriate pixels.
    % We still require the output of wait to determine whether or not
    % placement was cancelled.
    spatial_rect = h_rect.calculateClipRect(); 
    h_rect.delete();
else
    placement_cancelled = true;
end

end %interactiveCrop