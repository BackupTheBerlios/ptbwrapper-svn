%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayGabors.m
%
% Displays gabors to the screen.
%
% Args:
%	- sizes: [width height] pairs
%	- positions: The positions to put the pictures.
%	- duration: The length to display for.
%   - tag: A label to print out with the picture.
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayGabors({[50 50]}, {'center'}, {.3}, 'Gabor')
%
% Author: Doug Bemis
% Date: 3/13/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayGabors(sizes, positions, tilts, duration, tag, varargin)

% Parse any optional arguments and get the correct window
[trigger key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% TODO: Look into settings for gabors
res = 1*[323 323];
phase = 0;
sc = 50.0;
freq = .1;
contrast = 100.0;
aspectratio = 1.0;
tw = res(1);
th = res(2);
nonsymmetric = 0;

% Draw each
global PTBScreenRes;
for i = 1:length(sizes)

	% Build a procedural gabor texture for a gabor with a support of tw x th
	% pixels, and a RGB color offset of 0.5 -- a 50% gray.
	gabortex = CreateProceduralGabor(wPtr, tw, th, nonsymmetric, [0.5 0.5 0.5 0.0]);
	
	% Set the position from the size
	if strcmpi(positions{i}, 'center')
		positions{i} = [PTBScreenRes.width/2 PTBScreenRes.height/2];
	end
	pos = [positions{i}(1) - sizes{i}(1)/2 positions{i}(2) - sizes{i}(2)/2 ...
		positions{i}(1) + sizes{i}(1)/2 positions{i}(2) + sizes{i}(2)/2];		

	% Draw the gabor once, just to make sure the gfx-hardware is ready for the
	% benchmark run below and doesn't do one time setup work inside the
	% benchmark loop: See below for explanation of parameters...
	Screen('DrawTexture', wPtr, gabortex, [], pos, 90+tilts(i), [], [], [], [], kPsychDontDoRotation, [phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]);
end


% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Gabor', tag, trigger, key_condition);

