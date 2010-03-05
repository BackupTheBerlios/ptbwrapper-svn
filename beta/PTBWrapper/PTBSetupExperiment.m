%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetupExperiment.m
%
% Does the setup for a PTBExperiment. Should be called
% soonish in the experiment.
%
% Args:
%	- title: The name of the experiment.
%
% Usage: PTBSetupExperiment('VMod')
%
% This sets and provides various useful global
% values. NOTE: These can often be set at any time
% with the appropriate function.
%
%	- PTBCurrComputerSpecs: Some useful info about the 
%		current computer
%	- PTBTheWindowPtr: The pointer to the onscreen window.
%	- PTBScreenRes: Has 'width' and 'height' fields in pixels
%	- PTBStartTime: The time the experiment started (i.e.
%		when the start screen disappeared.
%	- PTBNextPresentationTime: When the next stimulus should be 
%		shown (usually set in PTBSetDuration).
%	- PTBLastPresentationTime: When the current stimulus was
%		shown.
%	- PTBWaitingForKey: True if we're waiting for a keypress
%		to show the next screen.
%	- PTBIsDebugging: True if we're debugging. This will
%		show only a portion of the screen. Timing will be
%		off because of the smaller screen.
%	- PTBExitKey: Will exit the program if given as a response.
%	- PTBLastKeyPressTime: The last time a key was recorded
%		as being pressed.
%	- PTBDataFileID: The file id to write responses to.
%	- PTBLogFileID: The file id to write stimulus presentations to.
%	- PTBLogAppend: This will be appended to any log line.
%	- PTBLastKeyPress: The last key given as a response.
%	- PTBBackgroundColor: The screen color.
%	- PTBInputDevice: The input device used for responses.
%	- PTBTextFont: The font for the text.
%	- PTBTextSize: The size for the text.
%	- PTBSoundState: 0 if sound has not been initialized.
%		- PTBSoundInitialized = 1
%		- PTBSoundOpen = 2
%		- PTBSoundPlaying = 3.
%	- PTBTheSoundPort: The sound port currently in use.
%	- PTBVisualStimulus: 1 if there is a visual stimulus to display.
%	- PTBAudioStimulus: 1 if there is a visual stimulus to display.
%   - PTBTriggerLength: The length of triggers sent to the MEG DAQs.
%	- PTBUSBBoxInitialized: 1 if USBBox has been initialized.
%	- PTBDisableTimeOut: 1 if want to collect a key press over multiple displays
%		* REMEMBER to set this back to 0 afterwards.
%	- PTBAddedResponseTime: Used internally when time out is disabled.
%	- PTBKeyQueue: A list of screens to show depending on a key press outcome.
%	- PTBTheScreenNumber: The screen number we're displaying to.
%	- PTBDisableKbQueue: 1 if queue needs to be disabled.
%		* This is always disabled in windows.
%
% Author: Doug Bemis
% Date: 7/3/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Eventually take variable args and parse.
% I.e.: Resolution, etc.
function PTBSetupExperiment(title)

% Versioning!
global PTBWrapper
PTBWrapperVersion;

% Setup the debugging flag. Default to not debugging.
global PTBIsDebugging
if isempty(PTBIsDebugging)
	PTBIsDebugging = 0;
end

% Setup the background color. Default to black.
global PTBBackgroundColor
if isempty(PTBBackgroundColor)
	PTBBackgroundColor = 0;
end

% Setup the exit key. Default to empty, which 
% means there will be no exit key.
global PTBExitKey
if isempty(PTBExitKey)
	PTBExitKey = '';
end

% Setup the input device. Default to -1, which 
% should be the keyboard.
global PTBInputDevice
if isempty(PTBInputDevice)
	PTBInputDevice = -1;
end

% Storage for the keys we're wating for now
global PTBKeysOfInterest
if isempty(PTBKeysOfInterest)
    PTBKeysOfInterest = zeros(1,256);
end

% Set the sound flags
global PTBSoundInitialized;
PTBSoundInitialized = 1;
global PTBSoundOpen;
PTBSoundOpen = 2;
global PTBSoundPlaying;
PTBSoundPlaying = 3;
global PTBSoundState
if isempty(PTBSoundState)
	PTBSoundState = 0;
end

% Just set to nothing for now
global PTBTheSoundPort;
if isempty(PTBTheSoundPort)
	PTBTheSoundPort = 0;
end

% Set the stimulus values
global PTBVisual;
PTBVisual = 1;
global PTBAudio;
PTBAudio = 2;

% Initialize the stimuli
global PTBVisualStimulus;
PTBVisualStimulus = 0;
global PTBAudioStimulus;
PTBAudioStimulus = 0;

% Initialize the trigger length
global PTBTriggerLength;
if isempty(PTBTriggerLength)
    PTBTriggerLength = 0.01;
end

% Set to default for timeout
global PTBDisableTimeOut;
if isempty(PTBDisableTimeOut)
	PTBDisableTimeOut = 0;
end
global PTBAddedResponseTime;
if isempty(PTBAddedResponseTime)
	PTBAddedResponseTime = 0;
end

% Make sure we don't error
global PTBUSBBoxInitialized;
PTBUSBBoxInitialized = 0;

% This is how long the start screen is on for.
startScreenTime = 1;

% We'll be using OpenGL functions, so make sure
% that's possible.
AssertOpenGL;

% Get some computer info
global PTBCurrComputerSpecs;
PTBCurrComputerSpecs = Screen('Computer');

% Set the queue. Only works in mac for now.
global PTBDisableKbQueue;
if isempty(PTBDisableKbQueue) 
	if PTBCurrComputerSpecs.osx
		PTBDisableKbQueue = 0;
	else
		PTBDisableKbQueue = 1;
	end
end


% Don't want the keypresses, but only for actual running, because
% need to reenable afterwards.
% TODO: Do we need flexibility here?
FlushEvents('keyDown');
if ~PTBIsDebugging

	% Careful with this call. Will supress output in matlab, which
	% is good, but, if not reset (i.e. because of an error) will
	% prevent any input from reaching matlab afterwards too.
	ListenChar(2);
	HideCursor;
else
	
	% TODO: Do we ever want this off?
	ListenChar(1);
end

% For now, always supress these for speed.
% NOTE: Should probably run or force run at least once per machine.
% TODO: Allow configurability.
global PTBOldVisualDebugLevel;
global PTBOldSupressAllWarnings;
PTBOldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
PTBOldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);


% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');

% Need the window
global PTBTheWindowPtr;
global PTBTheScreenNumber;

% NOTE: The use of max screens sets the display to be any
% secondary screen, if it exists.
% TODO: Allow configurability.
screens = Screen('Screens');
PTBTheScreenNumber = max(screens);

% These will store the usable drawing area of the screen
% we're about to use.
% TODO: Allow configurability.
global PTBScreenRes;
PTBScreenRes=Screen('Resolution', PTBTheScreenNumber);

% Clear the key queue
global PTBKeyQueue;
PTBKeyQueue = {};

% This is for internal use to store events that need to be displayed
global PTBEventQueue;
PTBEventQueue = {};

% TODO: Do we want the ability to change this here?
% If so, Screen('Resolutions', screenNumber) will list the
% possible resolutions to go with.

% TODO: Might want to use these to define colors
% in the future.
% WhiteIndex(theWindowPtr)
% BlackIndex(theWindowPtr)

% Grab the screen
PTBTheWindowPtr = PTBCreateScreen(PTBTheScreenNumber,1);

% This prevents the OS from getting in the way.
% TODO: Allow configurability.
Priority(MaxPriority(PTBTheWindowPtr));

% Setup the text
global PTBTextFont;
if isempty(PTBTextFont)
	PTBTextFont = 'Courier';
end
global PTBTextSize;
if isempty(PTBTextSize)
	PTBTextSize = 30;
end

% Show a start message
% TODO: Think about whether this is needed, or
% could be made better.
Screen('TextFont', PTBTheWindowPtr, PTBTextFont);
Screen('TextSize', PTBTheWindowPtr, PTBTextSize);

% Setup the startscreen
global PTBUseStartScreen;
if isempty(PTBUseStartScreen)
	PTBUseStartScreen = 1;
end
if PTBUseStartScreen
	Screen('DrawText', PTBTheWindowPtr, title, 50, 100, [255 255 255 255]);
	Screen('DrawText', PTBTheWindowPtr, ['Powered by PTB wrapper version: ' num2str(PTBWrapper.major)...
		'.' num2str(PTBWrapper.minor) '.' num2str(PTBWrapper.point)], 50, 180, [255 255 255 255]);
	if (PTBIsDebugging)
		Screen('TextSize', PTBTheWindowPtr, 25);
		 Screen('DrawText', PTBTheWindowPtr, 'Currently Debugging', 50, 260, [255 255 255 255]);
	end
end

% Record the first display
global PTBLastPresentationTime;
PTBLastPresentationTime = Screen('Flip', PTBTheWindowPtr);

% Show briefly
WaitSecs(startScreenTime);

% Make sure these are initialized
global PTBWaitingForKey;
PTBWaitingForKey = 0;
global PTBLastKeyPressTime;
PTBLastKeyPressTime = -1;
global PTBLastKeyPress;
PTBLastKeyPress = '';

% Default the append to nothing
global PTBLogAppend;
if isempty(PTBLogAppend)
	PTBLogAppend = {};
end

% Setup the logfiles. Default to logfile.txt
global PTBLogFileName;
global PTBDataFileName;
if isempty(PTBLogFileName)
	PTBSetLogFiles('logfile.txt');
end

% Now, initialize them.
PTBInitLogFiles;

% Set the next to go as soon as possible
global PTBNextPresentationTime;
PTBNextPresentationTime = GetSecs;

% Also, useful for timestamping
global PTBStartTime;
PTBStartTime = PTBNextPresentationTime;

% And print out the start
global PTBLogFileID;
global PTBDataFileID;
PTBWriteLog(PTBLogFileID, 'START', num2str(PTBStartTime), '', PTBStartTime);
if ~strcmp(PTBLogFileName, PTBDataFileName)
	PTBWriteLog(PTBDataFileID, 'START', num2str(PTBStartTime), '', PTBStartTime);
end
