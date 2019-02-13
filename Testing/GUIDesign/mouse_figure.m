function hFig = mouse_figure(hFig)
% MOUSE_FIGURE       mouse-friendly figure
%
% MOUSE_FIGURE() creates a figure (or modifies an existing one) that allows
% zooming with the scroll wheel and panning with mouse clicks, *without*
% first selecting the ZOOM or PAN tools from the toolbar. Moreover, zooming
% occurs to and from the point the mouse currently hovers over, instead of
% to and from the less intuitive "CameraPosition". 
%
%         Scroll: zoom in/out
%     Left click: pan
%   Double click: reset view to default view
%    Right click: set new default view
%
% LIMITATIONS: This function (re-)defines several functions in the figure 
% (WindowScrollWheelFcn, WindowButtonDownFcn, WindowButtonUpFcn and 
% WindowButtonMotionFcn), so if you have any of these functions already
% defined they will get overwritten. Also, MOUSE_FIGURE() only works 
% properly for 2-D plots. As such, it should only be used for simple, 
% first-order plots intended for "quick-n-dirty" data exploration.
%
% EXAMPLE:
%
%   mouse_figure;
%   x = linspace(-1, 1, 10000);
%   y = sin(1./x);
%   plot(x, y) 
%   
% See also figure, axes, zoom, pan.


% Please report bugs and inquiries to: 
%
% Name       : Rody P.S. Oldenhuis
% E-mail     : oldenhuis@gmail.com    (personal)
%              oldenhuis@luxspace.lu  (professional)
% Affiliation: LuxSpace sàrl
% Licence    : BSD


% If you find this work useful, please consider a donation:
% https://www.paypal.me/RodyO

    
    % initialize
    status         = '';  
    previous_point = [];
    zoom_timer     = [];
    zoom_start     = 0;
    
    % initialize axes
    if (nargin == 0) || ~ishandle(hFig)
        hFig  = figure;  
        hAxes = gca;
    else
        hAxes = get(hFig, 'CurrentAxes');
    end
    
    % only works properly for 2D plots
    [~,elevation] = view(hAxes);
    assert(abs(elevation) == 90,...
          [mfilename ':plot3D_not_supported'], ...
          [mfilename '() only works for 2-D plots.']);
        
    % get original limits
    original_xlim = get(hAxes, 'xlim');
    original_ylim = get(hAxes, 'ylim');
    
    % define zooming with scrollwheel, and panning with mouseclicks
    set(hFig, ...
        'WindowScrollWheelFcn' , @scroll_zoom,...
        'WindowButtonDownFcn'  , @pan_click,...
        'WindowButtonUpFcn'    , @pan_release,...
        'WindowButtonMotionFcn', @pan_motion);    
    
    % zoom in to the current point with the mouse wheel
    function scroll_zoom(varargin)
        
        % Double check if these axes are indeed the current axes
        if get(hFig, 'currentaxes') ~= hAxes
            return, end
        
        zoom_start = tic();
        
        % Calculate zoom factor        
        zoomfactor = min(max(1 - varargin{2}.VerticalScrollCount/15*2, 0.3), 1.7);
        
        % Adjust cursor
        if zoomfactor > 1
            setptr(hFig, 'glassplus');
        elseif zoomfactor < 1
            setptr(hFig, 'glassminus');
        end
        
        % get the axes limits
        xlim = get(hAxes, 'xlim');
        ylim = get(hAxes, 'ylim');
        
        % get the current camera position, and save the [z]-value
        cam_pos_Z = get(hAxes, 'CameraPosition'); 
        cam_pos_Z = cam_pos_Z(3);
        
        % get the current point
        old_position = get(hAxes, 'CurrentPoint'); 
        old_position(1,3) = cam_pos_Z;
        
        % Messing with the camera settings might mess up the view (relevant 
        % for displayed images that use "axis xy")
        [az,el] = view(hAxes);
        
        % Adjust camera position and view angle
        set(hAxes,...
            'CameraTarget'  , [old_position(1, 1:2), 0],...
            'CameraPosition', old_position(1, 1:3));
        
        camzoom(zoomfactor);
        
        % Restore view
        %[~,el] = view(hAxes);
        view(hAxes, az,el);
        
        % zooming with the camera has the side-effect of
        % NOT adjusting the axes limits. We have to correct for this:
        x_lim1 = (old_position(1,1) - min(xlim))/zoomfactor;
        x_lim2 = (max(xlim) - old_position(1,1))/zoomfactor;
        xlim   = [old_position(1,1) - x_lim1, old_position(1,1) + x_lim2];
        set(hAxes, 'xlim', xlim);
        
        y_lim1 = (old_position(1,2) - min(ylim))/zoomfactor;
        y_lim2 = (max(ylim) - old_position(1,2))/zoomfactor;
        ylim   = [old_position(1,2) - y_lim1, old_position(1,2) + y_lim2];
        set(hAxes, 'ylim', ylim);
        
        % set new camera position
        new_position         = get(hAxes, 'CurrentPoint');
        old_camera_target    = get(hAxes, 'CameraTarget');
        old_camera_target(3) = cam_pos_Z;
        new_camera_position  = old_camera_target - ...
                               (new_position(1,1:3) - old_camera_target(1,1:3));
        
        % Adjust camera target and position
        set(hAxes,...
            'CameraPosition', new_camera_position(1, 1:3),...
            'CameraTarget', [new_camera_position(1, 1:2), 0]);
        
        % We also have to re-set the axes to stretch-to-fill mode
        set(hAxes, ...
            'CameraViewAngleMode', 'auto',...
            'CameraPositionMode', 'auto',...
            'CameraTargetMode', 'auto');
                
        % When done zooming: reset mouse cursor 
        if isempty(zoom_timer)
            zoom_timer = timer('TimerFcn', @reset_cursor,...
                               'StopFcn' , @remove_timer);
            start(zoom_timer);
        end
        
        function reset_cursor(~,~)
            while true
                if toc(zoom_start) > 0.2
                    set(hFig, 'Pointer', 'arrow');                    
                    break;
                end
                pause(0.05);
            end            
        end        
        function remove_timer(~,~)
            delete(zoom_timer);
            zoom_timer = [];
        end
        
    end % function scroll_zoom
    
    % Pan upon mouse click
    function pan_click(varargin)
        
        % double check if these axes are indeed the current axes
        if get(hFig, 'currentaxes') ~= hAxes
            return, end
        
        % perform appropriate action
        switch lower(get(hFig, 'selectiontype'))  
            
            % start panning on left click
            case 'normal' 
                status         = 'down';
                previous_point = get(hAxes, 'CurrentPoint');  
                setptr(hFig, 'closedhand'); 
                
            % Reset view on double click
            case 'open' % double click (left or right)
                set(hAxes,...
                    'Xlim', original_xlim,...
                    'Ylim', original_ylim);  
                
            % Right click - set new reset state
            case 'alt'
%                 original_xlim = get(hAxes, 'xlim');
%                 original_ylim = get(hAxes, 'ylim');
                %Actually, increase x-window
                xl = get(hAxes, 'xlim');
                xl(2) = xl(2) + diff(xl)/4;
                set(hAxes, 'XLim', xl)
            case 'extend'
                xl = get(hAxes, 'xlim');
                xl(2) = xl(2) - diff(xl)/4;
                set(hAxes, 'XLim', xl)
        end
        
    end % function pan_click
    
    % release mouse button
    function pan_release(varargin)
        
        % double check if these axes are indeed the current axes
        if get(hFig, 'currentaxes') ~= hAxes
            return, end
        
        % just reset status and cursor      
        status = ''; 
        setptr(hFig, 'arrow'); 
        
    end % function pan_release
    
    % move the mouse (with button clicked)
    function pan_motion(varargin)
        
        % double check if these axes are indeed the current axes
        if get(hFig, 'currentaxes') ~= hAxes
            return, end
        
        % return if there isn't a previous point
        if isempty(previous_point)
            return, end  
        % return if mouse hasn't been clicked
        if isempty(status)
            return, end  
        
        % get current location (in pixels)
        current_point = get(hAxes, 'CurrentPoint');
        % get current XY-limits
        xlim = get(hAxes, 'xlim');  ylim = get(hAxes, 'ylim');     
        % find change in position
        delta_points = current_point - previous_point;  
        
        % Adjust limits
        set(hAxes, 'Xlim', xlim - delta_points(1)); 
        set(hAxes, 'Ylim', ylim - delta_points(3));
        
        % save new position
        previous_point = get(hAxes, 'CurrentPoint');
        
    end % function pan_motion
    
end

