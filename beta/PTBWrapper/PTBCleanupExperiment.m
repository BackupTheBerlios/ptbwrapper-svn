%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBCleanupExperiment.m
%
% Does the cleanup for a PTBExperiment. Call this
% if the screen is still up and you don't want it to be.
%
% Args:
%
% Usage: PTBCleanupExperiment
%
% Author: Doug Bemis
% Date: 7/3/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBCleanupExperiment

% Write the keystrokes, if necessary
global PTBKeyFileName;
if ischar(PTBKeyFileName)
	PTBLogKeyStrokes;
end

% Shutdown the sound
PTBCloseSoundPort;

% Make sure the last screen stays up for the desired time,
% if there is one.
global PTBNextPresentationTime;
global PTBVisualStimulus;
global PTBEventQueue;
global PTBKeyQueue;
if ~isempty(Screen('Windows'))
	
	% And clear
	PTBEventQueue = {};
	PTBKeyQueue = {};
	if PTBNextPresentationTime - GetSecs > 1000
		PTBNextPresentationTime = 0;
	end
	PTBVisualStimulus = 1;
	PTBPresentStimulus({0},'Cleanup', '',[],'');
end

% Restore preferences
global PTBOldVisualDebugLevel;
global PTBOldSupressAllWarnings;
if ~isempty(PTBOldVisualDebugLevel)
	Screen('Preference', 'VisualDebugLevel', PTBOldVisualDebugLevel);
	Screen('Preference', 'SuppressAllWarnings', PTBOldSupressAllWarnings);
end

% TODO: Look into garbage collection here.
global PTBCurrComputerSpecs;
if PTBCurrComputerSpecs.osx
    KbQueueRelease;
end
Priority(0);
ListenChar(0);
ShowCursor
Screen('CloseAll');
fclose('all');
clear all;

