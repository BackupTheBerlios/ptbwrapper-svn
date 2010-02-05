%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayMatrices.m
%
% Displays matrices to the screen. Allows arbitarily 
% created images to be displayed.
%
% U
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayMatrices(matrices, positions, duration, varargin)

% Parse any optional arguments
if length(varargin) < 1
    trigger = [];
else
    trigger = varargin{1};
end

% Need the current window
global PTBTheWindowPtr;

% Place each matrix
for i = 1:length(matrices)

	% TODO: Allow setting of size, orientation, position, etc.

	% A texture is a GL texture that renders quickly
	% TODO: Check for pict bigger than screen. No checking in MakeTexture.
	% TODO: Check optimizations, i.e. for rotating.
	m_tex = Screen('MakeTexture', PTBTheWindowPtr, matrices{i});

	% TODO: See how this works and how effective it is at 
	% saving time.
	% [resident [texidresident]] = Screen('PreloadTextures', windowPtr [, texids]);

	% Get the position
	% TODO: Error checking...
	if ischar(positions{i})
		if strcmp(positions{i},'center')
			pos = [];
		else
			error('Unknown position. Exiting...');
		end
	else
		pos = [positions{i}(1) - size(matrices{i},1)/2 positions{i}(2) - size(matrices{i},2)/2 ...
			positions{i}(1) + size(matrices{i},1)/2 positions{i}(2) + size(matrices{i},2)/2];
	end
	
	% And draw to the buffer
	Screen('DrawTexture', PTBTheWindowPtr, m_tex, [], pos);

	% TODO: Look into reusing textures.
	Screen('Close',m_tex);
	
end

% Save some memory.
% TODO: Allow keeping in memory
clear matrices;

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Matrix', 'TTest', trigger);
