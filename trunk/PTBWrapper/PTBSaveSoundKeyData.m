%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSaveSoundKeyData.m
%
% Save any sound key data that was recorded during the experiment.
%
% Args:
%
% Usage: PTBSaveSoundKeyData
%
% Author: Doug Bemis
% Date: 4/23/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Possibly allow changing during the experiment.
function PTBSaveSoundKeyData

global PTBSoundKeyData;
global PTBSoundFileName;
global PTBRecordAudio;

% We're done recording...
PTBRecordAudio = 0;

% If we have none, get out of here
if isempty(PTBSoundKeyData)
	return;
end

% Otherwise, write it to the file
wavwrite(transpose(PTBSoundKeyData), 44100, 16, PTBSoundFileName);
