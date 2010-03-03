%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWaitForKey.m
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
global PTBCurrComputerSpecs;
global PTBKeysOfInterest;
global PTBKeyTag;
global PTBKeyType;

% For now, just waiting for any key.
% TODO: Error check and extend.
pressed = 0;
while pressed == 0

    % Use the good stuff for mac...
    if PTBCurrComputerSpecs.osx

        % Grab the key, and record
        [pressed, firstPress] = KbQueueCheck;
        
     % ...otherwise, the bad stuff
    else
        
        % Check
    	[keyIsDown, timeSecs, keyCode] = KbCheck;
        
        % See if we got one we wanted
        if keyIsDown && (sum(PTBKeysOfInterest & keyCode) > 0)
            pressed = 1;
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
if pressed > 0

 
    % Handle queue responses
    if PTBCurrComputerSpecs.osx

        % Find the first key press
        % TODO: There's probably a better way to do this.
        % If only one key press, can do away with most of this.
        firstKey = find(firstPress == min(firstPress(find(firstPress > 0))));

        % Record the time and press
        PTBLastKeyPressTime = firstPress(firstKey);
        PTBLastKeyPress = KbName(firstKey);

        % Just stop listening for now
        KbQueueStop;
       
    % Or Windows responses
    else
        
        % Get the pressed key
        % TODO: This will wrongly record if two
        % of the response keys are pressed at the same
        % time...
        firstKey = min(find(PTBKeysOfInterest & keyCode > 0));
        
        % Record the time and press
        PTBLastKeyPressTime = timeSecs;
        PTBLastKeyPress = KbName(firstKey);

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
        if PTBCurrComputerSpecs.osx
        	KbQueueStop;
        end
        
		% Reset the flag.
		PTBWaitingForKey = 0;
		
		% No more added time
		PTBAddedResponseTime = 0;

	% Need to keep this running
	else
		PTBAddedResponseTime = PTBAddedResponseTime + PTBNextPresentationTime - PTBLastPresentationTime;
	end
end

% Done with this now.
% NOTE: Do NOT call this here. Causes matlab to
% crash randomly. Can just kep calling KbQueueCreate
% to change options.
% KbQueueRelease;
