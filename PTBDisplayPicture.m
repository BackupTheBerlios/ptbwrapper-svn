%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayPicture.m
%
% Displays a picture to the screen.
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayPicture(picture, duration, varargin)

% Parse any optional arguments
if length(varargin) < 1
    trigger = [];
else
    trigger = varargin{1};
end

% Need the current window
global PTBTheWindowPtr;

% TODO: Allow setting of size, orientation, position, etc.

% Need to load the picture
% TODO: Look into preloading, for time.
% TODO: Is imread the best thing to use here?
% TODO: Can also explicitly add format to this function, if needed.
imdata = imread(picture);

% A texture is a GL texture that renders quickly
% TODO: Check for pict bigger than screen. No checking in MakeTexture.
% TODO: Check optimizations, i.e. for rotating.
pic_tex = Screen('MakeTexture', PTBTheWindowPtr, imdata);

% Save some memory.
% TODO: Allow keeping in memory
clear imdata;

% TODO: See how this works and how effective it is at 
% saving time.
% [resident [texidresident]] = Screen('PreloadTextures', windowPtr [, texids]);

% And draw to the buffer
Screen('DrawTexture', PTBTheWindowPtr, pic_tex);

% TODO: Look into reusing textures.
Screen('Close',pic_tex);

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Picture', picture, trigger);
