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

function PTBDisplayBlank(duration, varargin)

% Parse any optional arguments and get the correct window
[trigger key_condition] = PTBParseDisplayArguments(varargin);

% Just display the empty back buffer here.

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% TODO: Maybe provide color option.
% TODO: Check to see if back buffer is actually empty.
PTBPresentStimulus(duration, 'Blank','',trigger, key_condition);
