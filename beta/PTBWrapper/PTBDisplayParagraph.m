%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayParagraph.m
%
% Displays many lines to the screen.
%
% Args:
%	- lines: The lines to display.
%	- positions: Their positions, the second argument is
%		the line spacing.
%	- duration: How long to display for.
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayParagraph({'Hello.','line 2'},{'center',30},{.3})
%
% Author: Doug Bemis
% Date: 7/5/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayParagraph(lines, positions, duration, varargin)

% Parse any optional arguments and get the correct window
[trigger  trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% Need the current window
global PTBScreenRes;
global PTBTextFont;
global PTBTextSize;
global PTBTextColor;

% Set text parameters
Screen('TextFont', wPtr, PTBTextFont);
Screen('TextSize', wPtr, PTBTextSize);

% Support centering
if ischar(positions{1})
	if strcmp(positions{1}, 'center')
		
		% Set the positions
		spacing = positions{2};
		positions = {};
		heights = [];
		for i = 1:length(lines)

			% Get the bounds
			bounds = Screen('TextBounds', wPtr, lines{i});

			% Set the first position
			positions{i}(1) = PTBScreenRes.width/2 - bounds(3)/2;
			
			% And keep a record of the heights
			heights(i) = bounds(4);
		end
		
		% Add in the line spacing
		totalHeight = sum(heights) + (length(lines)-1)*spacing;
		
		% Set the first one
		positions{1}(2) = PTBScreenRes.height/2 - totalHeight/2;
		
		% Set the heights accordingly
		for i = 2:length(lines)
			positions{i}(2) = positions{i-1}(2) + heights(i-1) + spacing;
		end
		
	else
		error('Bad positions option.');
	end
end

% Make sure we're ok.
if length(positions) ~= length(lines)
	error('Bad position argument.');
end

% Draw each line
for i = 1:length(lines)
	Screen('DrawText', wPtr, lines{i}, positions{i}(1), positions{i}(2), PTBTextColor);
end

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Paragraph', lines{i}, trigger,  trigger_delay, key_condition);
