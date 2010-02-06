%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Auditory_Sample.m
%
%  Runs a simple auditory discrimination experiment
%
%   Usage: Auditory_Sample
% 
% Author: Doug Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Auditory_Sample(subject)

% Set to debug, if we want to.
PTBSetIsDebugging(1);

% Set the background color.
PTBSetBackgroundColor(127);

% Set the exit key.
PTBSetExitKey('ESCAPE');

% Turn off the start screen.
PTBSetUseStartScreen(0);

% Where to write out the logs.
% NOTE: Set the keyfile name in order to log all the TRs
PTBSetLogFiles([subject '_log.txt'], [subject '_data.txt']);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5)
%Screen('Preference', 'SkipSyncTests', 1);

% Let's try our experiment
try

    % First, prepare everything to go
    PTBSetupExperiment('Auditory Sample');

	% Set which keyboard is which
	% First argument is device index of laptop, second for scanner.
	% NOTE: Switch these if keyboard input doesn't work correctly.
	% setKeyboards(2,1,mode);
	
	% The beginning screens
% 	if mode == 0
% 		PTBDisplayParagraph({'We will now run a few short scans.', 'Please lie as still as possible.'}, {'center', 30}, {'any'});
% 	else
% 		PTBDisplayText('Press any key to begin the practice.', 'center', {'any'});
% 	end
	
	% Do the runs
% 	for i = 1:length(run_lists)
% 
% 		% Display a ready screen, which reports which run.
% 		PTBDisplayParagraph({['Run ' num2str(i) ' of ' num2str(length(run_lists)) ' is about to begin.'], 'Please lie as still as possible.'}, {'center', 30}, {'any'});
% 
% 		% And go
 		performBlock;
% 	end
    
	% The end screens 
% 	if mode == 0
% 
% 		% Last structural
% 		PTBDisplayParagraph({'One last scan to go.', 'Please lie as still as possible.'}, {'center', 30}, {'any'});
% 
% 		% And, we're done
% 		PTBDisplayParagraph({'The experiment is now over.', 'We will be right in.'}, {'center', 30}, {'any'});
% 		
% 	else
% 		PTBDisplayText('The practice is now over.','center',{'any'});	
% 	end
	
	% And finish up
    PTBCleanupExperiment;

catch
	PTBHandleError;
end


% Helper Functions

% Show one run
function performBlock

% This helps to tie timing to the first TR.
global PTBLastKeyPressTime;

% Cede control to the scanner
global scanner_kb;
%PTBSetInputDevice(scanner_kb);

% Wait for the first backtick to begin.
%PTBDisplayText('The next run is about to begin.', 'center', {'`~'});

% Skip the first couple of TRs for warmup
% if mode == 0 || mode == 2
% 	warmupTime = 8;
% else
% 	warmupTime = 1;
% end
% PTBDisplayText('+', 'center', {warmupTime});
% 
% Initialize the last trial time.
% This will always be an idealized time,
% to avoid getting off. So, should never
% set to lastDisplayTime in any way.
% LastKeyPress should coincide with the
% the first backtick from the scanner.
lastTrialEnd = PTBLastKeyPressTime;

% Open up the stimulus file
%fid = fopen(stim_file);

% Go through the trials
% TODO: Allow presetting / loading of
% trials to improve timing.
%while 1

	% Grab the next line
% 	line = fgetl(fid);
% 	if ~ischar(line)
% 		break;
% 	end
	
	% Parse the stimuli
	% TODO: Still don't understand why strread returns
	% cells instead of strings. Hence the {1}s...
%	[condition item_num fixation modifier object target answer ITI] = strread(line,'%s%f%s%s%s%s%s%f');

	% Want to know the trial type
%	PTBSetLogAppend(condition{1},num2str(item_num),answer{1});
	
	% Do the next trial
	lastTrialEnd = performTrial(lastTrialEnd);

%end
%fclose(fid);

% Cool down, to let the last BOLD subside
% if mode == 0
% 	cooldownTime = 8;
% else
% 	cooldownTime = 1;
% end
% PTBDisplayText('+', 'center', {cooldownTime + lastTrialEnd});
% 
% % Grab the input back
% global laptop_kb;
% PTBSetInputDevice(laptop_kb);
% 
% % And, we're done
% if mode == 0
% 	PTBDisplayParagraph({'The run is now over.','Please try to remain still.'}, {'center',30},{'any'});
% else
% 	PTBDisplayText('The run is now over.', 'center',{'any'});
% end
% 
% % Quick blank to make sure the last screen stays on
% PTBDisplayBlank({1});

% Show one trial
% NOTE: Using absolute / ideal timing for
% better precision.
% NOTE: The trialTime parameter essentially
% controls the timeout, for now.
function end_time = performTrial(start_time)

% Parameters
ITI = .5;

% if mode == 0
% 	match_key = '4$';
% 	nomatch_key = '3#';
% else
	match_key = '[{';
	nomatch_key = ']}';
end

% For practice
global PTBLastKeyPressTime;
global PTBLastKeyPress;

% First the fixation and blank
PTBPlaySound(fixation, {start_time + trial_time});
trial_time = trial_time + ISI_1;
PTBDisplayBlank({start_time + trial_time});

% Then, the modifier and blank
trial_time = trial_time + mod_time;
PTBDisplayPicture(modifier, {start_time + trial_time});
trial_time = trial_time + ISI_2;
PTBDisplayBlank({start_time + trial_time});

% Then, the object and blank
trial_time = trial_time + obj_time;
PTBDisplayPicture(object, {start_time + trial_time});
trial_time = trial_time + ISI_3;
PTBDisplayBlank({start_time + trial_time});

% The target will end with a response, or a timeout.
% The fixation will then remain through the ITI until
% the start of the next trial.
trial_time = trial_time + time_out;
PTBDisplayPicture(target, {match_key,nomatch_key,start_time + trial_time});

% If practicing, give some feedback
if mode == 1

	% Show a blank, also allows us to 
	% collect the last key press
	PTBDisplayBlank({p_ISI});

	% Show feedback
	trial_time = PTBLastKeyPressTime - start_time + p_ISI + p_feedback_time;
	if (strcmp(PTBLastKeyPress,match_key) && strcmpi(answer,'match')) ||...
		(strcmp(PTBLastKeyPress,nomatch_key) && strcmpi(answer,'nomatch'))
		PTBDisplayText('Correct!','center',{start_time + trial_time});
	elseif (strcmp(PTBLastKeyPress,nomatch_key) && strcmpi(answer,'match')) ||...
		(strcmp(PTBLastKeyPress,match_key) && strcmpi(answer,'nomatch'))
		PTBDisplayText('Incorrect.','center',{start_time + trial_time});

	% Might have timed out
	else
		trial_time = GetSecs + p_time_out_time - start_time;
		PTBDisplayText('Please respond faster.','center',{start_time + trial_time});
	end

end

% And wait for the ITI to end.
end_time = start_time + trial_time + ITI;
PTBDisplayText('+', 'center', {end_time});

% Helper to work with the scanner
% TODO: Incorporate into PTB, if can figure out
% which is which automatically
function setKeyboards(laptop, scanner,mode)

% Make them global
global laptop_kb;
global scanner_kb;

% See if we have two
kbs = GetKeyboardIndices;
if mode == 0
	if length(kbs) < 2
		PTBDisplayText('WARNING: Not reading from the scanner','center',{'any'});
		laptop = 1;
		scanner = 1;
	elseif length(kbs) > 2
		error('More than two inputs detected. Exiting...');
	end
	
% For practice, don't check
else
	laptop = 1;
	scanner = 1;
end
laptop_kb = kbs(laptop);
scanner_kb = kbs(scanner);

% Set to use the laptop first
PTBSetInputDevice(laptop_kb);


    