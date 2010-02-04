%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBInitSound.m
%
% Initializes the sound driver. Good luck...
% Args:
%	- latency: 0 for no low-latency, 1 for low-latency
%		- If 1 crashes, use 0...
%
% Usage: PTBPlaySoundFile(1)
%
% Author: Doug Bemis
% Date: 1/21/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBInitSound(latency)

% The 1 is for low-latency...
global PTBSoundState
global PTBSoundInitialized;
if PTBSoundState == 0
	InitializePsychSound(latency);
	PTBSoundState = PTBSoundInitialized;
end