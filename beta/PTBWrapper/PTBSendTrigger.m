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

function PTBSendTrigger(triggers, triggers_delay)

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
triggers_delay = triggers_delay - PTBTriggerLength;
triggers_delay(1) = triggers_delay(1) + PTBTriggerLength;
for i = 1:length(triggers)

    % Sometimes need to delay, because it gets there before the screen
    pause(triggers_delay(i));

    % Send the trigger
    trig_time = GetSecs;
    PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)+triggers(i)));
    pause(PTBTriggerLength);
    PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)));
end

% Want to record
global PTBLogFileID;
PTBWriteLog(PTBLogFileID, 'TRIGGER', 'USBBox', num2str(triggers), trig_time);	

    