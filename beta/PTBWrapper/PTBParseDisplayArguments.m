%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBParseDisplayArguments.m
%
% NOTE: For internal use.
% TODO: Move to separate folder.
%
% Parses the arguments for the Display calls
% Args:
%	- args: The arguments to parse
%
% Usage: PTBParseDisplayArguments(varargin)
%
% Author: Doug Bemis
% Date: 3/2/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [trigger key_condition wPtr] = PTBParseDisplayArguments(duration, args)

% Default if none
trigger = [];
key_condition = '';

% Parse any we have
for i = 1:length(args)
	
	% Take all numbers to be triggers
	if isnumeric(args{i})
		trigger = args{i};
	
	% Take all strings to be key conditions
	elseif ischar(args{i})
		key_condition = args{i};
	end
end

% Get or make the appropriate window pointer
global PTBTheWindowPtr;
global PTBKeyQueue;
global PTBTheScreenNumber;
global PTBLastWindowPtr;

if ~isempty(PTBLastWindowPtr)
	wPtr = PTBLastWindowPtr;
elseif isempty(key_condition)
	wPtr = PTBTheWindowPtr;
else
	wPtr = PTBCreateScreen(PTBTheScreenNumber,0);
	PTBKeyQueue{end+1} = {key_condition, wPtr};
end

% Might want to keep using the pointer next time
if duration{1} == -1
	PTBLastWindowPtr = wPtr;
else
	PTBLastWindowPtr = [];
end

