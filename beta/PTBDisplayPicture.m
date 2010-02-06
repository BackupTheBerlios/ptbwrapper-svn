%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayPicture.m
%
% Displays a picture to the screen.
%
% Args:
%	- picture: The picture file to display
%	- duration: The length to display for.
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayPicture('Test.jpg',{.3})
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayPicture(picture, duration, varargin)

% TODO: Allow setting of size, orientation, position, etc.

% Need to load the picture
% TODO: Look into preloading, for time.
% TODO: Is imread the best thing to use here?
% TODO: Can also explicitly add format to this function, if needed.
imdata = {};
imdata{1} = imread(picture);

% Lean on the matrices routine
PTBDisplayMatrices(imdata, {'center'}, duration, varargin);

