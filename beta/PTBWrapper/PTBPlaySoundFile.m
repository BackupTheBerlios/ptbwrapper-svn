%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBPlaySoundFile.m
%
% Plays a given .wav file
%
% Args:
%	- soundfile: The file to play
%	- duration: How long to play for
%
% Usage: PTBPlaySoundFile('soundfile.wav',{.3})
%
% Author: Doug Bemis
% Date: 1/21/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBPlaySoundFile(soundfile, duration, varargin)

% Parse any optional arguments and get the correct window
[trigger  trigger_delay key_condition] = PTBParseDisplayArguments(duration, varargin);

% Perform basic initialization of the sound driver, to be sure
PTBInitSound(1);

% Close down any open ports
PTBCloseSoundPort;

% Read WAV file from filesystem:
[y, freq] = wavread(soundfile);
wavedata = y';
nrchannels = size(wavedata,1); % Number of rows == number of channels.

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
global PTBTheSoundPort;
global PTBSoundState;
global PTBSoundOpen;
PTBTheSoundPort = PsychPortAudio('Open', [], [], 1, freq, nrchannels);
PTBSoundState = PTBSoundOpen;

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', PTBTheSoundPort, wavedata);

% Set the type...
global PTBAudioStimulus;
PTBAudioStimulus = 1;

% And go...
PTBPresentStimulus(duration, 'Soundfile', soundfile, trigger,  trigger_delay, key_condition);
