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

function PTBSendTrigger(value)

% Check
global PTBUSBBoxInitialized;
if ~PTBUSBBoxInitialized
	disp('WARNING: No trigger sent.');
	return;
end

% Trigger seems to get there too fast.
% Despite the fact that the flip and trigger times are
% the same
trigger_delay = 0.016;

% Send the trigger
global PTBUSBBoxDeviceID;
global PTBTriggerLength;
pause(trigger_delay);
trig_time = GetSecs;
PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)+value));
pause(PTBTriggerLength);
PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)));

trig_time_2 = GetSecs;


% Want to record
global PTBLogFileID;
PTBWriteLog(PTBLogFileID, 'TRIGGER', 'USBBox', num2str(value), trig_time);	

    