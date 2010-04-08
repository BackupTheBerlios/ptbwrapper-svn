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
% Usage: PTBDisplayPictures({'Test.jpg'}, {'center'}, {1}, {.3},'Stim')
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayPictures(pictures, positions, scales, duration, tag, varargin)

% Parse any optional arguments and get the correct window
[trigger trigger_delay key_condition] = PTBParseDisplayArguments(duration, varargin);

% TODO: Allow setting of size, orientation, position, etc.

% Need to load the picture
% TODO: Look into preloading, for time.
% TODO: Is imread the best thing to use here?
% TODO: Can also explicitly add format to this function, if needed.
imdata = {};
for i = 1:length(pictures)
	
	% Load the data
	[data map alpha] = imread(pictures{i});

	% Add the alpha if necessary
	if isempty(alpha)
		imdata{i} = data;
	else
		imdata{i} = zeros(size(data,1),size(data,2),4);
		imdata{i}(:,:,1:3) = data;
		imdata{i}(:,:,4) = alpha;
	end
	
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
PTBDisplayMatrices(imdata, positions, duration, tag, trigger, trigger_delay, key_condition);

