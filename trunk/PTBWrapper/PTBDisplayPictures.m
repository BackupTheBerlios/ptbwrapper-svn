%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayPicture.m
%
% Displays a picture to the screen.
%
% Args:
%	- pictures: The picture files to display.
%	- positions: The positions to put the pictures.
%	- scales: The scales to show the pictures at.
%		- Can be a single numeric value
%		- Or [num_rows num_cols]. 
%			- Either can be NaN, which will keep the aspect ratio.
%	- duration: The length to display for.
%   - tag: A label to print out with the picture.
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayPictures({'Test.jpg'}, {'center'}, {.3})
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayPictures(pictures, positions, scales, duration, tag, varargin)

% TODO: Figure out best way to pass through varargin.
% Right now, it becomes wrapped in too many {}s
if length(varargin) > 1
    error('Too many varargs for now. Exiting...');
end
arg = '';
if ~isempty(varargin) > 0
    arg = varargin{1};
end

% TODO: Allow setting of size, orientation, position, etc.

% Need to load the picture
% TODO: Look into preloading, for time.
% TODO: Is imread the best thing to use here?
% TODO: Can also explicitly add format to this function, if needed.
imdata = {};
for i = 1:length(pictures)
	imdata{i} = imread(pictures{i});
	
	% Might not have it (it's in a toolbox)
	if length(scales{i}) ~= 1 || scales{i} ~= 1
		try
			imdata{i} = imresize(imdata{i}, scales{i});
		catch
			err = lasterror;
			disp(['WARNING: Resizing not possible: ' err.message]);
		end		
	end
end

% Lean on the matrices routine
PTBDisplayMatrices(imdata, positions, duration, tag, arg);

