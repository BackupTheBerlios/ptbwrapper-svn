%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetLogAppend.m
%
% Sets data to append at the end of each log line.
%
% Args:
%	- Comma delimited strings to add.
%
% Usage: PTBSetLogAppend('Condition','Item')
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Figure out the funcationality we want here.
function PTBSetLogAppend(varargin)

% Clear and set
global PTBLogAppend;
PTBLogAppend = {};
for i = 1:nargin
	PTBLogAppend{i} = varargin{i};
end
