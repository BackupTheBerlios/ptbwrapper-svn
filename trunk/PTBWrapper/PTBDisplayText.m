%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayText.m
%
% Displays text to the screen.
% Args:
%	- text: The text to display.
%	- position: Either 'center' to center the text or [x y].
%	- duration: How long to show the the text.
%
% NOTE: Position is the top of the text.
% NOTE: Only 'center' is as a cell...
%
% Usage: PTBDisplayText('Hello world.',{'center'},{.2})
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayText(text, position, duration, varargin)

% Parse any optional arguments and get the correct window
[trigger key_condition wPtr] = PTBParseDisplayArguments(varargin);

% Need the current window size for centering
global PTBScreenRes;
global PTBTheScreenNumber;

% TODO: Allow setting of font, size, color
Screen('TextFont', wPtr, 'Courier');
Screen('TextSize', wPtr, 30);
tColor = WhiteIndex(PTBTheScreenNumber);

% Need to check
% TODO: Possibly turn these check off if not debugging?
if ~ischar(text)
	error('Bad text input.');
end

% Check for special positions
if iscell(position)
	if strcmpi(position{1},'center')
		
		% Get the bounds of the text
		bounds = Screen('TextBounds', wPtr, text);
		
		% Set the centered position
		p = [PTBScreenRes.width/2 - bounds(3)/2 PTBScreenRes.height/2 - bounds(4)/2];
		
		% Might want to offset
		% TODO: Add error checking...
		if length(position) == 2
			position = p + position{2}; 
		else
			position = p;
		end
	else
		error(['Unknown position: ' position]);
	end
elseif ~isnumeric(position)
	error('Bad position argument.');
end
Screen('DrawText', wPtr, text, position(1), position(2), tColor);

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Text', text, trigger, key_condition);
