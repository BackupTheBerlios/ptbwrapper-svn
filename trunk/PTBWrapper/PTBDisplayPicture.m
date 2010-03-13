%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayPicture.m
%
% Displays a picture to the screen.
%
% Args:
%	- picture: The picture file to display
%	- duration: The length to display for.
%   - tag: A label to print out with the picture.
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayPicture('Test.jpg',{.3})
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayPicture(picture, position, duration, tag, varargin)

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
imdata{1} = imread(picture);

% Lean on the matrices routine
PTBDisplayMatrices(imdata, {'center'}, duration, tag, arg);

