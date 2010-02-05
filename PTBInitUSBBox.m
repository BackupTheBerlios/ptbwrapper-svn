%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBInitUSBBox.m
%
% Initializes the IOLab USB ButtonBox
%
% Usage: PTBInitUSBBox
%
% Author: Doug Bemis
% Date: 1/21/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBInitUSBBox

% Attempt to find the device number for the
% IOLab USB Box
devices = squeeze(struct2cell(PsychHID('devices')));
devices_id = cell2mat(devices(6,:));
results = find(devices_id == 6588);
if isempty(results)
    error('BBox not found. Exiting...');
end;

% Set all the triggers to 0
global PTBUSBBoxDeviceID;
global PTBUSBBoxInitialized;
PTBUSBBoxDeviceID = results(1);
PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8([0 0]));
disp('BBox found and ready to go.');
PTBUSBBoxInitialized = 1;