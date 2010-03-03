%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetDisableKbQueue.m
%
% Turns the queue on or off
%
% Args:
%	- value: 1 to queue should be disabled.
%
% Usage: PTBDisableKbQueue(1)
%
% Author: Doug Bemis
% Date: 3/2/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetDisableKbQueue(value)

% Set
global PTBDisableKbQueue;
PTBDisableKbQueue = value;
