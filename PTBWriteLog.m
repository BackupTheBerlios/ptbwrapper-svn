%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWriteLog.m
%
% Write out a line to a log file.
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBWriteLog(fid, event, type, tag, time)

% Append anything we need
global PTBLogAppend;

% Make all times relative to the start, as default
global PTBStartTime;

% Write out the line
% TODO: Think about buffering and not
% touching the file every time.
line = [event '\t' type '\t' tag '\t' num2str(time - PTBStartTime)];
for i = 1:length(PTBLogAppend)
	line = [line '\t' PTBLogAppend{i}];
end

% And print
fprintf(fid,[line '\n']);