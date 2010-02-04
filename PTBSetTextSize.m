%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetTextSize.m
%
% Sets the text size.
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetTextSize(value)

% Set
global PTBTextSize;
PTBTextSize = value;

global PTBTheWindowPtr;
if ~isempty(PTBTheWindowPtr)
	Screen('TextSize', PTBTheWindowPtr, 30);
end