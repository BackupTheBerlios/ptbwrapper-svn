%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSendTrigger.m
%
% Initializes the IOLab USB ButtonBox
%
% Args:
%	- value: 0-255 trigger value to send
%
% Usage: PTBSendTrigger(30)
%
% Author: Doug Bemis
% Date: 2/3/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSendTrigger(value, trigger_delay)

% Check
global PTBUSBBoxInitialized;
if ~PTBUSBBoxInitialized
	disp('WARNING: No trigger sent.');
	return;
end

% Send the trigger
global PTBUSBBoxDeviceID;
global PTBTriggerLength;

% Sometimes need to delay, because it gets there before the screen
pause(trigger_delay);

% Send the trigger
trig_time = GetSecs;
PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)+value));
pause(PTBTriggerLength);
PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)));


% Want to record
global PTBLogFileID;
PTBWriteLog(PTBLogFileID, 'TRIGGER', 'USBBox', num2str(value), trig_time);	

    