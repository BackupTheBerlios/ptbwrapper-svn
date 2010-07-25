%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWaitForKey.m
%
% NOTE: Internal function. DO NOT CALL.
%
% This waits for a key to be pressed and records it.
%
% Usage: PTBWaitForKey
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBWaitForKey

global PTBWaitingForKey;
global PTBLastPresentationTime;
global PTBNextPresentationTime;
global PTBExitKey;
global PTBLastKeyPressTime;
global PTBLastKeyPress;
global PTBDisableTimeOut;
global PTBAddedResponseTime;
global PTBKeysOfInterest;
global PTBKeyTag;
global PTBKeyType;
global PTBInputCollection;
global PTBInputDevice;

% For now, just waiting for any key.
% TODO: Error check and extend.
pressed = 0;
while pressed == 0

    % Use the good stuff for mac...
    if strcmp(PTBInputCollection, 'Queue')

        % Grab the key, and record
        [pressed, firstPress] = KbQueueCheck;
        
     % ...otherwise, the bad stuff
	elseif strcmp(PTBInputCollection, 'Check')
        
        % Check the current input device
    	[keyIsDown, timeSecs, keyCode] = KbCheck(PTBInputDevice);
        
        % See if we got one we wanted
        if keyIsDown && (sum(PTBKeysOfInterest & keyCode) > 0)
            pressed = 1;
		end
		
	% ...or the really bad stuff
	elseif strcmp(PTBInputCollection, 'Char')

		% Check for a character
		while CharAvail
			
			% See if we wanted it
			[ch when] = GetChar;
			
			% TODO: Fix errors from control keys
			try
				if PTBKeysOfInterest(KbName(ch)) > 0
					pressed = 1;

					% NOTE: The 'when' is really bad, so, just
					% do was well as we can.
					char_press_time = GetSecs;
					break;
				end
			catch
				% Just keep going for now...
			end
		end
    end
    
    % See if we've timed out
    timeOutCheck = GetSecs;
    if timeOutCheck > PTBNextPresentationTime

        % TODO: Slight chance that a button 
        % was pressed during the last loop. 
        % Should probably check...
        pressed = -1;
        break;
    end

end

% Either got a press...
global PTBDataFileID;
global PTBEndTriggers;
if pressed > 0

    % Handle queue responses
	% Need to set PTBLastKeyPressTime and PTBLastKeyPress
    if strcmp(PTBInputCollection, 'Queue')

        % Find the first key press
        % TODO: There's probably a better way to do this.
        % If only one key press, can do away with most of this.
        firstKey = find(firstPress == min(firstPress(find(firstPress > 0))));

        % Record the time and press
        PTBLastKeyPressTime = firstPress(firstKey);
        PTBLastKeyPress = KbName(firstKey);

        % Just stop listening for now
        KbQueueStop;
        KbQueueRelease;
       
    % Or Windows responses
	elseif strcmp(PTBInputCollection, 'Check')
        
        % Get the pressed key
        % TODO: This will wrongly record if two
        % of the response keys are pressed at the same
        % time...
        firstKey = min(find(PTBKeysOfInterest & keyCode > 0));
        
        % Record the time and press
        PTBLastKeyPressTime = timeSecs;
        PTBLastKeyPress = KbName(firstKey);
		
	elseif strcmp(PTBInputCollection, 'Char')

		% Record the time and press
		firstKey = KbName(ch);
        PTBLastKeyPressTime = char_press_time;
        PTBLastKeyPress = ch;
	end
	
	% Send a trigger, if necessary
	if ~isempty(PTBEndTriggers)
		
		% Check for matching
		for i = 1:length(PTBEndTriggers)
			if strcmp(PTBEndTriggers{i}{1},'any') || strcmp(PTBEndTriggers{i}{1}, PTBLastKeyPress)
				PTBSendTrigger(PTBEndTriggers{i}{2}, PTBEndTriggers{i}{3});
			end
		end
	end

	% Get response time
	RT = PTBAddedResponseTime + PTBLastKeyPressTime - PTBLastPresentationTime;
	
	% Make a record
	PTBWriteLog(PTBDataFileID, 'KEY', PTBLastKeyPress, num2str(RT), PTBLastKeyPressTime, PTBKeyType, PTBKeyTag);
	
	% For now, always clear when get a key
	PTBNextPresentationTime = 0;
	
	% Check the exit key
	if KbName(PTBExitKey) == firstKey
		error('Exit key pressed.');
	end

	% Reset the flag.
	PTBWaitingForKey = 0;
	
	% No more added time
	PTBAddedResponseTime = 0;

% ...or timed out.
else
	
	%  Only record if we're not disabled
	if ~PTBDisableTimeOut
		PTBLastKeyPress = 'TIMEOUT';
		PTBLastKeyPressTime = -1;
		PTBWriteLog(PTBDataFileID, 'TIMEOUT','', '', timeOutCheck, PTBKeyType, PTBKeyTag);

		% Just stop listening for now
        if strcmp(PTBInputCollection, 'Queue')
        	KbQueueStop;
            KbQueueRelease;
		end
        		
		% And clear
		FlushEvents();

		% Reset the flag.
		PTBWaitingForKey = 0;
		
		% No more added time
		PTBAddedResponseTime = 0;

	% Need to keep this running
	else
		PTBLastKeyPress = 'TIMEOUT';
		PTBAddedResponseTime = PTBAddedResponseTime + PTBNextPresentationTime - PTBLastPresentationTime;
	end
end

% Done with this now.
% NOTE: Do NOT call this here. Causes matlab to
% crash randomly. Can just kep calling KbQueueCreate
% to change options.
% KbQueueRelease;
