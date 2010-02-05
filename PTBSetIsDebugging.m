%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetIsDebugging.m
%
% Sets the debugging flag.
%
% Args:
%	- value: 1 to use the debugging setup.
%
% Usage: PTBSetIsDebugging(1)
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetIsDebugging(value)

% Set
global PTBIsDebugging;
PTBIsDebugging = value;
