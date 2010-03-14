%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayBlank.m
%
% Just display a blank screen.
%
% Args:
%	- duration: The length to display
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayBlank({.3})
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBDisplayBlank(duration, tag, varargin)

% Parse any optional arguments and get the correct window
[trigger trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% Clear it
global PTBBackgroundColor;
Screen('FillRect', wPtr, PTBBackgroundColor);

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% TODO: Maybe provide color option.
% TODO: Check to see if back buffer is actually empty.
PTBPresentStimulus(duration, 'Blank', tag, trigger, trigger_delay, key_condition);
