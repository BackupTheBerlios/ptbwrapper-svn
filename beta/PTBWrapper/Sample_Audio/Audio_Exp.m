%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Audio_Exp.m
%
% Runs a simple auditory discrimination experiment.
%
% Args:
%	- subject: The subject id.
%	- stim_lists: The lists of blocks to run.
%	- mode: How we're running:
%		- 0: In the scanner.
%		- 1: Practice with feedback
%		- 2: Practice without feedback
%
% Usage: Audio_exp('AB',{'stim_list_1.txt','stim_list_2.txt'},0)
%
% Author: Doug Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Audio_Exp(subject,stim_lists,mode)

% The inputs
% NOTE: Might need to switch these - depends on 
% the USB ports, etc....
keyboard_id = 1;
button_box_id = 2;

% Set to debug, if we want to.
PTBSetIsDebugging(1);

% Set the background color.
PTBSetBackgroundColor(127);

% Set the exit key.
PTBSetExitKey('ESCAPE');

% Where to write out the logs.
% NOTE: Set the keyfile name in order to log all the TRs
PTBSetLogFiles([subject '_log.txt'], [subject '_data.txt']);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5)
%Screen('Preference', 'SkipSyncTests', 1);

% Let's try our experiment
try

    % First, prepare everything to go
    PTBSetupExperiment('Gsharp');

	% The beginning screens
 	if mode == 0
		PTBDisplayParagraph({'The experiment is about to begin.', 'Please lie still.'}, {'center', 30}, {'any'});
	else
		PTBDisplayParagraph({'The practice is about to begin.', 'Press any key.'}, {'center', 30}, {'any'});
	end
	
	% Do the blocks
 	for i = 1:length(stim_lists)

		% Switch input if in machine
		if mode == 0
			PTBSetInputDevice(button_box_id);
		end
		
		% Display a ready screen, which reports which run.
		PTBDisplayParagraph({['Block ' num2str(i) ' of ' num2str(length(stim_lists)) ' is about to begin.'], 'Please press any key when ready.'}, {'center', 30}, {'any'});

		% And go...
		performBlock(stim_lists{i},mode);
				
		% Let them know they're done
		if mode == 0
			PTBSetInputDevice(keyboard_id);
			PTBDisplayParagraph({['Block ' num2str(i) ' of ' num2str(length(stim_lists)) ' is now over.'], 'Please lie still.'}, {'center', 30}, {'any'});
		else
			PTBDisplayParagraph({['Block ' num2str(i) ' of ' num2str(length(stim_lists)) ' is now over.'], 'Please press any key when ready.'}, {'center', 30}, {'any'});
		end
 	end
    
	% The end screens 
	if mode == 0
		PTBDisplayText('The experiment is now over.', 'center', {'any'});
	else
		PTBDisplayText('The practice is now over.','center',{'any'});	
	end

	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1});
	
	% And finish up
    PTBCleanupExperiment;

catch
	PTBHandleError;
end


% Helper Functions

% Show one run
function performBlock(stim_file,mode)

% Just put a blank screen up for now
PTBDisplayBlank({.1});

% Open up the stimulus file
fid = fopen(stim_file);

% Go through the trials
% TODO: Allow presetting / loading of
% trials to improve timing.
while 1

	% Grab the next line
	line = fgetl(fid);
	if ~ischar(line)
		break;
	end
	
	% Parse the stimuli
	% TODO: Still don't understand why strread returns
	% cells instead of strings. Hence the {1}s...
	[condition item_num wavefile ITI] = strread(line,'%s%f%s%f');

	% Want to know the trial type
	PTBSetLogAppend(condition{1},num2str(item_num));
	
	% Do the next trial
	performTrial(wavefile{1},condition{1},ITI,mode);

end
fclose(fid);


% Show one trial
function performTrial(wavfilename, condition, ITI, mode)

% The response keys
if mode == 0
	cond_1_key = '1!';
	cond_2_key = '2@';
else
	cond_1_key = '[{';
	cond_2_key = ']}';
end

% Play the trial
PTBPlaySoundFile(wavfilename,{cond_1_key,cond_2_key});

% For practice
global PTBLastKeyPress;

% If practicing, give some feedback
if mode == 1

	% Show a blank, also allows us to 
	% collect the last key press
	PTBDisplayBlank({.3});

	% Show feedback
	if (strcmp(PTBLastKeyPress,cond_1_key) && strcmpi(condition,'c1')) ||...
		(strcmp(PTBLastKeyPress,cond_2_key) && strcmpi(condition,'c2'))
		PTBDisplayText('Correct!','center',{1});
	else 
		PTBDisplayText('Incorrect.','center',{1});
	end

end

% And wait for the ITI to end.
PTBDisplayBlank({ITI});

    