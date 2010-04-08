%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetDuration.m
%
% This is setup to do all the preparation to
% display while the previous screen is being viewed.
% Therefore, we simply use the duration to set
% the time for the next display, and move on to 
% preparing it.
%
% Args:
%	- duration: The duration to use
%
% Usage: PTBSetDuration({.3,'any'})
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetDuration(duration, tag, type)

global PTBLastPresentationTime;
global PTBNextPresentationTime;
global PTBTheWindowPtr;
global PTBWaitingForKey;
global PTBExitKey;
global PTBInputDevice;
global PTBKeyTag;
global PTBKeyType;
global PTBInputCollection;

% Make sure we can parse
if ~iscell(duration)
	error('Bad duration.');
end

% TODO: Probably only need to do this once at the start.
% TODO: This is unnecessary and wrong for audio stimuli. But, have
% to figure out what's next. Maybe subtract at presentation of next audio?
slack = Screen('GetFlipInterval', PTBTheWindowPtr);

% The keys that we'll be waiting for
global PTBKeysOfInterest;
if ~PTBWaitingForKey
    PTBKeysOfInterest=zeros(1,256);
end

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
		PTBKeysOfInterest = ones(1,256);

	% Set a response key
	else
		PTBKeysOfInterest(KbName(duration{i}))=1;
	end
end

% Set up the queue, if waiting for a key
global PTBDisableTimeOut;
if sum(PTBKeysOfInterest) > 0
	
	% Add the exit key, if needed
	PTBKeysOfInterest(KbName(PTBExitKey)) = 1;
	
	% TODO: Should probably build for the
	% delay associated with checking the key
	% before timing out. Or move to PTBWaitForKey.
	% i.e. nextDisplayTime = nextDisplayTime - 0.015.
	
    % Queue functions only work for mac and then, 
	% only sometimes
    if strcmp(PTBInputCollection, 'Queue')

        % TODO: Figure out deviceNumbers.
        % NOTE: Do NOT call KbQueueRelease, unless 
        % you really feel it's necessary. This should 
        % act to change the parameters of the queue
        % and KbQueueRelease causes crashes.
        KbQueueCreate(PTBInputDevice, PTBKeysOfInterest);

        % Clear it here.
        % TODO: Figure out how much funcationality
        % we want here.
        KbQueueFlush;

        % Start up the queue and keep going.
        KbQueueStart;	
		
	% Otherwise, wait for the input to clear
	elseif strcmp(PTBInputCollection, 'Check')

		% Wait for all keys to be released, if we're not
		% holding over
		if ~PTBDisableTimeOut
			KbWait(PTBInputDevice,1);
		end
		
	% Or, simply clear
	else
		if ~PTBDisableTimeOut
			FlushEvents('KeyDown');
		end
	end
	
	% Mark that we're waiting
	PTBWaitingForKey = 1;
	
	% And record what we're waiting at
	PTBKeyTag = tag;
	PTBKeyType = type;
	
end

