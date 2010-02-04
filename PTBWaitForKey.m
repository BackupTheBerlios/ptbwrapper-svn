%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWaitForKey.m
%
% This waits for a key to be pressed and records it.
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

% For now, just waiting for any key.
% TODO: Error check and extend.
pressed = 0;
while pressed == 0

	% Grab the key, and record
	[pressed, firstPress] = KbQueueCheck;

	% See if we've timed out
	timeOutCheck = GetSecs;
	if timeOutCheck > PTBNextPresentationTime
	
		% TODO: Slight change that a button 
		% was pressed during the last loop. 
		% Should probably check...
		pressed = -1;
		break;
	end
end

% Either got a press...
global PTBDataFileID;
if pressed > 0

	% Find the first key press
	% TODO: There's probably a better way to do this.
	% If only one key press, can do away with most of this.
	firstKey = find(firstPress == min(firstPress(find(firstPress > 0))));

	% Record the time and press
	PTBLastKeyPressTime = firstPress(firstKey);
  	PTBLastKeyPress = KbName(firstKey);
		
	% Make a record
	PTBWriteLog(PTBDataFileID, 'KEY', PTBLastKeyPress, num2str(PTBLastKeyPressTime - PTBLastPresentationTime), PTBLastKeyPressTime);
	
	% For now, always clear when get a key
	PTBNextPresentationTime = 0;
	
	% Check the exit key
	if KbName(PTBExitKey) == firstKey
		error('Exit key pressed.');
	end

% ...or timed out.
else
	PTBLastKeyPress = 'TIMEOUT';
	PTBLastKeyPressTime = -1;
	PTBWriteLog(PTBDataFileID, 'TIMEOUT','', '', timeOutCheck);
end

% Done with this now.
% NOTE: Do NOT call this here. Causes matlab to
% crash randomly. Can just kep calling KbQueueCreate
% to change options.
% KbQueueRelease;

% Just stop listening for now
KbQueueStop;

% Reset the flag.
PTBWaitingForKey = 0;
