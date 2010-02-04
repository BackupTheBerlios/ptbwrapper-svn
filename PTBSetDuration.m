%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetDuration.m
%
% This is setup to do all the preparation to
% display while the previous screen is being viewed.
% Therefore, we simply use the duration to set
% the time for the next display, and move on to 
% preparing it.
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetDuration(duration)

global PTBLastPresentationTime;
global PTBNextPresentationTime;
global PTBTheWindowPtr;
global PTBWaitingForKey;
global PTBExitKey;
global PTBInputDevice;

% Make sure we can parse
if ~iscell(duration)
	error('Bad duration.');
end

% TODO: Probably only need to do this once at the start.
% TODO: This is unnecessary and wrong for audio stimuli. But, have
% to figure out what's next. Maybe subtract at presentation of next audio?
slack = Screen('GetFlipInterval', PTBTheWindowPtr);

% The keys that we'll be waiting for
keysOfInterest=zeros(1,256);

% Set for no time out, if no duration set
% An hour should do it.
PTBNextPresentationTime = PTBLastPresentationTime + 3600;

% Setup all the conditions
for i = 1:length(duration)
	
	% If numeric, just set and go
	if isnumeric(duration{i})

		% Need to adjust for refresh rate
		% TODO: Why does the pdf slides use Screen('GetFlipInterval', theWindowPtr) / 2?
		% TODO: Still needs some work (off by about 1ms, but consistently fast.
		% Much more testing needed...

		% If duration is over 200, assume we're setting an absolute
		% duration instead of relative. 
        % TODO: Make this better
		if (duration{i} > 200)
			PTBNextPresentationTime = duration{i} - slack;
		else
			PTBNextPresentationTime = PTBLastPresentationTime + duration{i} - slack;
		end
		
	% Special 'anykey'
	elseif strcmpi(duration{i}, 'any')
		keysOfInterest = ones(1,256);

	% Set a response key
	else
		keysOfInterest(KbName(duration{i}))=1;
	end
end
	
% Set up the queue, if waiting for a key
if sum(keysOfInterest) > 0
	
	% Add the exit key, if needed
	keysOfInterest(KbName(PTBExitKey)) = 1;
	
	% TODO: Should probably build for the
	% delay associated with checking the key
	% before timing out. Or move to PTBWaitForKey.
	% i.e. nextDisplayTime = nextDisplayTime - 0.015.
	
	% TODO: Figure out deviceNumbers.
	% NOTE: Do NOT call KbQueueRelease, unless 
	% you really feel it's necessary. This should 
	% act to change the parameters of the queue
	% and KbQueueRelease causes crashes.
	KbQueueCreate(PTBInputDevice, keysOfInterest);
	
	% Clear it here.
	% TODO: Figure out how much funcationality
	% we want here.
	KbQueueFlush;
	
	% Start up the queue and keep going.
	KbQueueStart;	
	
	% Mark that we're waiting
	PTBWaitingForKey = 1;
end

