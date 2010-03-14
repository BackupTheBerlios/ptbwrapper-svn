%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBPresentStimulus.m
%
% This is mainly used internally.
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
% Usage: PTBSetBackgroundColor(duration, type, tag, trigger)
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBPresentStimulus(duration, type, tag, trigger, trigger_delay, key_condition)

% Wait until we want to display
global PTBTheWindowPtr;
global PTBTheSoundPort;
global PTBSoundState;
global PTBNextPresentationTime;
global PTBLastPresentationTime;
global PTBAudioStimulus;
global PTBVisualStimulus;


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

% Don't display if we have a key_condition.
% These will be held in a queue until the next
% key press.
global PTBKeyQueue;
if ~isempty(key_condition)
	
	% Set the relevant values for later and return
	% NOTE: Go from the back forward to add multiple displays
	% for key
	for i = length(PTBKeyQueue):-1:1
		if strcmp(PTBKeyQueue{i}{1}, key_condition)
			
			% NOTE: First two are key and window pointer
			PTBKeyQueue{i}{3} = duration;
			PTBKeyQueue{i}{4} = type;
			PTBKeyQueue{i}{5} = tag;
			PTBKeyQueue{i}{6} = trigger;
			PTBKeyQueue{i}{7} = trigger_delay;
			PTBKeyQueue{i}{8} = PTBVisualStimulus;
			PTBKeyQueue{i}{9} = PTBAudioStimulus;
			
			break;
		end
	end
	
	% Go back for another
	return;
end

% Wait, if necessary
global PTBWaitingForKey;
global PTBLastKeyPress;
global PTBEventQueue;
global PTBTheScreenNumber;
if PTBWaitingForKey
	
	% Wait until we get it
	PTBWaitForKey;
	
	% See if we've got a queue to check
	tmpScreen = {};
	for i = 1:length(PTBKeyQueue)
		
		% If we get one, move the current display to the
		% last one.
		if strcmp(PTBKeyQueue{i}{1}, PTBLastKeyPress)
			
			% If this is the first, put it on the screen to display
			if isempty(tmpScreen)
			
				% First, keep the current screen
				ptr = PTBCreateScreen(PTBTheScreenNumber,0);
				Screen('CopyWindow',PTBTheWindowPtr,ptr);
				tmpScreen = {ptr, duration, type, tag, trigger, trigger_delay, PTBVisualStimulus, PTBAudioStimulus};			

				% Now, copy the queued display to show and the parameters
				Screen('CopyWindow',PTBKeyQueue{i}{2},PTBTheWindowPtr);
				duration = PTBKeyQueue{i}{3};
				type = PTBKeyQueue{i}{4};
				tag = PTBKeyQueue{i}{5};
				trigger = PTBKeyQueue{i}{6};
				trigger_delay = PTBKeyQueue{i}{7};
				PTBVisualStimulus = PTBKeyQueue{i}{8};
				PTBAudioStimulus = PTBKeyQueue{i}{9};
	
				% And done with the old one
				Screen('Close',PTBKeyQueue{i}{2});
			
			% Otherwise, put in the queue
			else
				PTBEventQueue{end+1} = {PTBKeyQueue{i}{2}, PTBKeyQueue{i}{3}, PTBKeyQueue{i}{4}, ...
					PTBKeyQueue{i}{5}, PTBKeyQueue{i}{6}, PTBKeyQueue{i}{7}, PTBKeyQueue{i}{8}};
			end

		% Otherwise, not going to use it
		else
			Screen('Close',PTBKeyQueue{i}{2});
		end
		
	end
	
	% Move the current to the end of the queue, if we have one
	if ~isempty(tmpScreen)
		PTBEventQueue{end+1} = tmpScreen;
	end
	
	% Reset the queue
	PTBKeyQueue = {};
end

% And present the stimulus
if PTBAudioStimulus && PTBVisualStimulus
	
	% Have to compromise here. 
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
    PTBSendTrigger(trigger, trigger_delay);
end

% Reset here
% TODO: Have to  
PTBAudioStimulus = 0;
PTBVisualStimulus = 0;

% Provide a log, to check timing
% TODO: See if this is taking up time, and allow 
% eliminating it.
PTBWriteLog(PTBLogFileID, 'STIM', type, tag, PTBLastPresentationTime);

% Set the next screen
PTBSetDuration(duration, tag, type);

% If we've got an event queue, just loop through
if ~isempty(PTBEventQueue)

	% Find the first non-empty event
	for i = 1:length(PTBEventQueue)
		if ~isempty(PTBEventQueue{i})

			% Copy the first event over
			Screen('CopyWindow',PTBEventQueue{i}{1},PTBTheWindowPtr);
			duration = PTBEventQueue{i}{2};
			type = PTBEventQueue{i}{3};
			tag = PTBEventQueue{i}{4};
			trigger = PTBEventQueue{i}{5};
			trigger_delay = PTBEventQueue{i}{6};
			PTBVisualStimulus = PTBEventQueue{i}{7};
			PTBAudioStimulus = PTBEventQueue{i}{8};
			
			% Close the window down
			Screen('Close',PTBEventQueue{i}{1});
			
			% If we're at the end, clear
			if i == length(PTBEventQueue)
				PTBEventQueue = {};
				
			% Otherwise, just clear this one
			else
				PTBEventQueue{i} = {};
			end
			break;
		end
	end

	% Recursively call (Shouldn't cause too much problems...)
	PTBPresentStimulus(duration, type, tag, trigger, trigger_delay, '')
end




