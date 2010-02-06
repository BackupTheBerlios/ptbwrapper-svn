%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetBackgroundColor.m
%
% Sets the background screen color.
%
% Args:
%	- value: The color
%
% Usage: PTBSetBackgroundColor(127)
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetBackgroundColor(value)

% Set
global PTBBackgroundColor;
PTBBackgroundColor = value;
