%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBParseDisplayArguments.m
%
% NOTE: Internal function. DO NOT CALL.
%
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

function [trigger trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, args)

% Default if none
trigger = [];
trigger_delay = [];
key_condition = '';

% Parse any we have
for i = 1:length(args)
	if ~isempty(args{i})

		% Take all numbers to be triggers
		if isnumeric(args{i})
			trigger(end+1) = args{i};

			% Second argument could be a delay
			trigger_delay(end+1) = 0;
			if length(args) > i
				if isnumeric(args{i+1})
					trigger_delay(end) = args{i+1};
					args{i+1} = '';
				end				
			end
		% Take all strings to be key conditions
		elseif ischar(args{i})
			key_condition = args{i};
		end
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
if isnumeric(duration{1}) && (duration{1} == -1)
	PTBLastWindowPtr = wPtr;
else
	PTBLastWindowPtr = [];
end

