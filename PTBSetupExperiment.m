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
%
% Author: Doug Bemis
% Date: 7/3/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Eventually take variable args and parse.
% I.e.: Resolution, etc.
function PTBSetupExperiment(title)

% Versioning!
global PTBMajorVersion;
PTBMajorVersion = 0;
global PTBMinorVersion;
PTBMinorVersion = 2;
global PTBRevision;
PTBRevision = 0;

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
if isempty(PTBVisualStimulus)
	PTBVisualStimulus = 0;
end
global PTBAudioStimulus;
if isempty(PTBAudioStimulus)
	PTBAudioStimulus = 0;
end

% Initialize the trigger length
global PTBTriggerLength;
if isempty(PTBTriggerLength)
    PTBTriggerLength = 0.01;
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

% Aiming for cross-platformness, at some point...
% The main problem right now is that KbQueue functions
% are the best for timing and only work for mac.
if (~PTBCurrComputerSpecs.osx)
	error('Sorry. Only Mac supported for now...')
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

% NOTE: The use of max screens sets the display to be any
% secondary screen, if it exists.
% TODO: Allow configurability.
screens = Screen('Screens');
screenNumber = max(screens);

% These will store the usable drawing area of the screen
% we're about to use.
% TODO: Allow configurability.
global PTBScreenRes;
PTBScreenRes=Screen('Resolution', screenNumber);

% TODO: Do we want the ability to change this here?
% If so, Screen('Resolutions', screenNumber) will list the
% possible resolutions to go with.

% TODO: Might want to use these to define colors
% in the future.
% WhiteIndex(theWindowPtr)
% BlackIndex(theWindowPtr)


% For now, keep double-buffered and default pixel depth, and 
% open with black color.
% Also, make a smaller screen for debugging, and always a
% full screen for running.
if (PTBIsDebugging)
	PTBScreenRes.width = PTBScreenRes.width*.75;
	PTBScreenRes.height = PTBScreenRes.height*.75;
	PTBTheWindowPtr = Screen('OpenWindow', screenNumber, PTBBackgroundColor, [0 0  PTBScreenRes.width PTBScreenRes.height]);
else
	PTBTheWindowPtr = Screen('OpenWindow', screenNumber, PTBBackgroundColor);
end

% Set alpha blending on, just in case we want it
% TODO: Does this break anything?
Screen(PTBTheWindowPtr,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

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
	Screen('DrawText', PTBTheWindowPtr, ['Powered by PTB wrapper version: ' num2str(PTBMajorVersion)...
		'.' num2str(PTBMinorVersion) '.' num2str(PTBRevision)], 50, 180, [255 255 255 255]);
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
