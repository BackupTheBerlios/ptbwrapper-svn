%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayLines.m
%
% Displays lines to the screen.
%
% Args:
%	- positions: Where to put the lines
%	- size: The width of the lines
%	- duration: How long to show the the text.
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayText([0 0; 100 100]',{.2})
%
% Author: Doug Bemis
% Date: 2/3/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayLines(positions, size, duration, varargin)

% Parse any optional arguments and get the correct window
[trigger key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% TODO: Allow setting of font, size, color
%Screen('TextFont', PTBTheWindowPtr, 'Courier');
%Screen('TextSize', PTBTheWindowPtr, 30);
%tColor = WhiteIndex(PTBTheWindowPtr);

% Draw the circles
% TODO: High-quality breaks stuff without alpha blending on
% TODO: Maybe allow resetting of center?
% TODO: Handle positions more generally across different display functions.
quality = 0;
center = [0 0];
color = 255;
Screen('DrawLines', wPtr, positions, size, color, center, quality);

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Lines', '\t', trigger, key_condition);
