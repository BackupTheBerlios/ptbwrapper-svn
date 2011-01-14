%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSendTrigger.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Sends a trigger to the USBBox.
%
% Args:
%	- value: 0-255 trigger values to send
%   - trigger_delay: The delays to use for each trigger.
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

% Send the triggers
global PTBUSBBoxDeviceID;
global PTBTriggerLength;

    
% Account for the trigger length for any triggers after the first
trigger_delay = trigger_delay - PTBTriggerLength;
trigger_delay(1) = trigger_delay(1) + PTBTriggerLength;

% NOTE: value can have more than 1 trigger
for i = 1:length(value)

    % Sometimes need to delay, because it gets there before the screen
    pause(trigger_delay(i));

    % Send the trigger
    trig_time = GetSecs;
    PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)+value(i)));
    pause(PTBTriggerLength);
    PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)));
end

% Want to record
global PTBLogFileID;
PTBWriteLog(PTBLogFileID, 'TRIGGER', 'USBBox', num2str(value), trig_time);	

    