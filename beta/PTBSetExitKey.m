%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetExitKey.m
%
% Sets the exit key. Hitting this key for any response
% will exit the program.
%
% Args:
%	- value: The key to set.
%
% Usage: PTBSetExitKey('ESCAPE')
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetExitKey(value)

% Set
global PTBExitKey;
PTBExitKey = value;
