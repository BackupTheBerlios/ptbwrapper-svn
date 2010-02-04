%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBPresentStimulus.m
%
% Displays the backbuffer to the screen.
% This should be called whenever the stimulus has
% been created and is ready to display.
%
% This function will then wait to display the
% stimulus until the previous stimulus is done (or
% ASAP, if it's late) and will schedule the time for the
% next stimulus.
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBPresentStimulus(duration, type, tag, trigger)

% Wait until we want to display
global PTBTheWindowPtr;
global PTBTheSoundPort;
global PTBSoundState;
global PTBNextPresentationTime;
global PTBLastPresentationTime;


% A duration of -1 means that we're putting more than
% one stimulus on the screen
global PTBLogFileID;
if ~iscell(duration) 
	error('Bad duration');
end
if duration{1} == -1
	
	% Record and return
	PTBWriteLog(PTBLogFileID, 'STIM_PREPARE', type, tag, -1);	
	return;
end

% Wait, if necessary
global PTBWaitingForKey;
if PTBWaitingForKey
	PTBWaitForKey;
end

% And present the stimulus
global PTBAudioStimulus;
global PTBVisualStimulus;
if PTBAudioStimulus && PTBVisualStimulus
	
	% Have to comprise here. 
	% TODO: Figure out which is better to go first.
	PsychPortAudio('Start', PTBTheSoundPort, 1, PTBNextPresentationTime, 0);
	PTBLastPresentationTime = Screen('Flip', PTBTheWindowPtr, PTBNextPresentationTime);	
	PTBSoundState = 3;
elseif PTBAudioStimulus
	PTBLastPresentationTime = PsychPortAudio('Start', PTBTheSoundPort, 1, PTBNextPresentationTime, 1);
	PTBSoundState = 3;
elseif PTBVisualStimulus
	PTBLastPresentationTime = Screen('Flip', PTBTheWindowPtr, PTBNextPresentationTime);
else
	error('Unknown stimulus type.');
end

% Send the trigger here, if necessary
if ~isempty(trigger)
    PTBSendTrigger(trigger);
end

% Reset here
PTBAudioStimulus = 0;
PTBVisualStimulus = 0;

% Provide a log, to check timing
% TODO: See if this is taking up time, and allow 
% eliminating it.
PTBWriteLog(PTBLogFileID, 'STIM', type, tag, PTBLastPresentationTime);

% Set the next screen
PTBSetDuration(duration);


