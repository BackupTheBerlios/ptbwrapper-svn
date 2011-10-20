%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBStopEyeTrackerRecording.m
%
% Stop the eyelink eye tracker recording
%
% Usage: PTBStopEyeTrackerRecording
%
% Author: Doug Bemis
% Date: 10/12/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBStopEyeTrackerRecording

global PTBEyeTrackerRecording;
global PTBEyeTrackerInitialized;
global PTBEyeTrackerFileName;

% Should have already sent a message before, so just return now...
if ~PTBEyeTrackerInitialized
	return;
end

% Stop
% TODO: Do we need to check that we've started?
Eyelink('Stoprecording');
PTBEyeTrackerRecording = 0;

% Close down the file
status = Eyelink('CloseFile');
disp(['Got status ' num2str(status) ' for command for close file.']);
if status ~= 0
    error('Eyetracker file not closed.');
end

status = Eyelink('ReceiveFile',PTBEyeTrackerFileName, PTBEyeTrackerFileName);
disp(['Got status ' num2str(status) ' for command for receive file.']);
if status < 0
    error('Eyetracker file not received.');
end
if ~exist(PTBEyeTrackerFileName, 'file')
    error('Eyetracker file not found.');
end



