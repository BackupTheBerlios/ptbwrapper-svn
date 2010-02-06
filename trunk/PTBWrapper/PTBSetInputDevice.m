%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetInputDevice.m
%
% Sets the input device.
%
% Args:
%	- device_num: The device to read from.
%
% Usage: PTBSetInputDevice(1);
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetInputDevice(device_num)

% Grab them
kbs = GetKeyboardIndices;

% Get the appropriate one
if device_num > length(kbs)
	disp('WARNING: Fewer inputs than expected. Defaulting...');
	value = kbs(1);
else
	value = kbs(device_num);
end

% Set
global PTBInputDevice;
PTBInputDevice = value;
