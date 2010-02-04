%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBCloseSoundPort.m
%
% Stops and closes a sound port, if open.
% NOTE: This is only called when another one is needed.
% TODO: Figure out if this is bad...
%
% Usage: PTBCloseSound
%
% Author: Doug Bemis
% Date: 1/21/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBCloseSoundPort

global PTBTheSoundPort;
global PTBSoundState;
global PTBSoundInitialized;
global PTBSoundOpen;
global PTBSoundPlaying;

% Only close if open.
if PTBSoundState == PTBSoundPlaying
	PsychPortAudio('Stop', PTBTheSoundPort);
	PTBSoundState = PTBSoundOpen;
end
if PTBSoundState == PTBSoundOpen
	PsychPortAudio('Close', PTBTheSoundPort);
	PTBSoundState = PTBSoundInitialized;
end

