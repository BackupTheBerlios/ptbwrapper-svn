%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetTextFont.m
%
% Sets the text font.
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetTextFont(value)

% Set
global PTBTextFont;
PTBTextFont = value;

global PTBTheWindowPtr;
if ~isempty(PTBTheWindowPtr)
	Screen('TextFont', PTBTheWindowPtr, 'Courier');
end