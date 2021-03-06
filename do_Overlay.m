function do_Overlay(im_underlay,im_overlay,options)
% function do_Overlay(im_underlay,im_overlay,options)
% 
% Provide a normalised colour overlay between two different images, known
% as im_underlay (the background), and im_overlay (the foreground). 
% 
% The in-plane (x, y) size of the background and foreground must be the
% same. If the overlay is 3D, a movie will be made (with 'pause' statements
% between each iteration) overlaying over the 3rd dimension. The colour
% axis is normalised to the largest point across all times. For the case of
% a movie, the background will be constant. 
% 
% Options is a struct containing several useful things. Defaults are
% provided. 
%
% Options can contain: 
%   hfig -- figure handle for overlay window 
%   hax -- axis handle (blank is fine) 
%   do_normslice = 1 -- normalise each slice 
%   orient =1 -- change to rotate 
%   overlay_flag = 'abs' -- function to call on overlayed data
%   cmap = 'jet' -- overlay colour scheme 
%   bgnd_bright = 0.6 -- brightness of the background [underlay] 
%   gamma_background = 0.5 -- gamma adjustment of the background 
%   fov_x = 1 -- adjust to crop 
%   fov_y = 1 -- adjust to crop 
%   zoomFactor = 1.5 -- size of resulting window 
%   cutBottom = 0.45 -- bottom of the colour axis (below which is
%   transparent)
%   cutTop = 1  -- top of the colour axis (above which is red) 
%   saveVideo = false -- set to true to save a video 
%   videoName = a unique string -- filename 
%   overlayString  -- text to write on each video frame 
%
%
%
%  JJM 2015


if ~isequal([size(im_underlay,1) size(im_underlay,2)],[size(im_overlay,1) size(im_overlay,2)])
    error('Underlay and overlay images must be the same in-plane size'); 
end

if nargin > 3 
    error('Provide options as param struct');     
end

if nargin == 2
    options=struct([]); 
end

if nargin < 2 
    error('Check input'); 
end

im_c=im_overlay;


%%Parse options 
defaultOptions.hfig = 2;
defaultOptions.hax = [];
defaultOptions.do_normslice = 1;
defaultOptions.orient = 1;
defaultOptions.overlay_flag = 'abs';

% choose a colourmap
defaultOptions.cmap = 'jet';

defaultOptions.bgnd_bright = 0.6;
defaultOptions.gamma_background = 0.5;
defaultOptions.gamma_foreground = 1;
defaultOptions.fov_x = 1.0;
defaultOptions.fov_y = 1.0;
defaultOptions.zoomFactor=1.5;
defaultOptions.cutBottom=0.475; 
defaultOptions.cutTop=1; 

defaultOptions.saveVideo=false;
defaultOptions.videoName=datestr(now,'yy-mm-dd__HH_MM_SS');
defaultOptions.doTimes=false; 


defaultOptions.do_overlay_writing=false; 
defaultOptions.overlayString=''; 
defaultOptions.times=[]; 


Options=mergeOptions(defaultOptions,options);

if strcmp(Options.overlayString,'times'); 
    Options.doTimes=true; 
end

%%End options parsing here


% find the maxima over all frames
im_max = max(abs(im_c(:)));
if Options.saveVideo
    vidObj = VideoWriter(Options.videoName);
    vidObj.FrameRate=1.5;
    vidObj.Quality=100;
    open(vidObj);
end


for j=1:size(im_c,3)
    
    im_over = im_c(:,:,j);
    
    % For each frame, we scale to the maximum over the entire time series.
    
    max_scale = (1./(max(abs(im_over(:))) / im_max));
    f_bot = max_scale * Options.cutBottom;
    f_top = max_scale * Options.cutTop;
    
    overlay4d( im_over, im_underlay, ...
        Options.hfig, Options.hax, Options.do_normslice, Options.orient, ...
        Options.overlay_flag, f_bot, f_top, ...
        Options.cmap, Options.bgnd_bright, Options.gamma_background,...
        Options.gamma_foreground, ...
        Options.fov_x, Options.fov_y );
    
    
    pos=get(gcf, 'Position');
    set(gcf, 'Position',[pos(1) pos(2) Options.zoomFactor*pos(3) Options.zoomFactor*pos(4)]);
    
    
    if Options.do_overlay_writing
        if Options.doTimes
            Options.overlayString=sprintf('\\color{white}T: %.1f s',Options.times((3*(j-1)+1)));
        end
        text(10,10,Options.overlayString);
    end
    
    if size(im_c,3) > 1 
    pause;
    end 
    if Options.saveVideo
        currFrame = getframe;
        writeVideo(vidObj, currFrame);
        
    end
end
if Options.saveVideo
    close(vidObj);
end

end