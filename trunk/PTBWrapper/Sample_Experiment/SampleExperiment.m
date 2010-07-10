%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Sample_Experiment.m
%
% Runs an audio and visual experiment. The basic task is to determine whether or 
% not a presented picture matches the word(s) that come(s) before it. The Comp(osition)
% task requires that the picture match all of the words. The List task requires that
% the picture match any of the preceeding words. The response keys are 1 (match)
% and 2 (nomatch). To get past the recording screens, hit 'a'.
%
% There are many comments below that should be useful in using PTBWrapper.
%
% Args:
%	- subject: The subject id, can be any string.
%		* This will be prepended to the log and data files.
%   - task_order: 1: {Comp, List}; 2: {List, Comp}; 3: {Comp}; 4: {List}
%	- mod_order: 1: {V, A}; 2: {A, V}; 3: {V}; 4: {A}
%	- is_outside: Set to 1 if outside the MEG. This will just run the 
%		first practice with and without feedback. 0 will run both tasks
%		with a practice run and no feedback at the beginning and
%		two practice runs for the second task.
%
% NOTE: This will recreate the stimulus lists every time.
%
% Usage: Sample_Experiment('Subj_Label',1,1,0)
%
% Author: Doug Bemis
% Date: 7/9/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SampleExperiment(subject, task_order, mod_order, is_outside)

% The practice numbers.
% This is used below to determine the number of practice
% trials we'll use.
num_practice_1 = 12;
num_practice_2 = 8;

% These parameters can be used to restart the experiment from
% a given point, if it is interrupted (e.g. by excessive noise).
start_task = 1;
start_mod = 1;
start_block = 1;
create_stim_lists = 1;

% The inputs. These are used below to control the input
% method.
keyboard_id = 2;
button_box_id = 1;

% Make sure we're compatible.
% This call will make sure that the script can always
% be rerun properly, even if PTBWrapper is updated
% to a future version. Set this to whatever version
% works with the final script.
PTBVersionCheck(1,1,5,'exactly');

% Set to debug, if we want to.
% If this is set to 1, the display will not take up the whole
% screen. This is useful if you crash something or get
% stuck in an infinite loop, as you can then just click
% in the Matlab window. To get out of the experiment, 
% then hit ctrl-c, to stop it running. Then, type
% PTBCleanupExperiment, to close the screen. 
% If this doesn't work, type Screen('CloseAll'), and this
% should close the display.
PTBSetIsDebugging(0);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5). Sometimes the display
% is slow to load when in debugging mode. If you
% uncomment this line, this will no longer cause 
% an error. However, it should be commented
% back in when debugging is done.
% Screen('Preference', 'SkipSyncTests', 1);

% See PTBSetInputCollection for details.
% For now, only Char (the worst option) seems to work for
% the MEG right now and Mac combination.
% We're looking into this...
collection_type = 'Queue';
PTBSetInputCollection(collection_type);

% Set the exit key. 
% This option allows you to exit the program
% at any response by hitting the specified key.
if strcmp(collection_type, 'Char')
	PTBSetExitKey('0');
else	
	PTBSetExitKey('ESCAPE');
end

% Where to write out the logs. This should give
% you all the information about what was displayed (log.txt)
% and what the responses were (data.txt).
PTBSetLogFiles([subject '_log.txt'], [subject '_data.txt']);

% Can include the setup scree.
PTBSetUseStartScreen(1);

% This is a useful set function.
% In general, if you would like to set an option (e.g.
% text size or color, etc.) check the PTBWrapper folder.
% Various Set functions are transparently enclosed in 
% functions there.
PTBSetBackgroundColor([128 128 128]);

% Experiment parameters.
% The rest of these options are for this specific experiment
% and not particularly relevant to PTBWrapper in general.
% For more help with that, skip down to the 'try' statement.

% Colors to use
colors = {'Red', 'Blue', 'Pink', 'Black', 'Green', 'Brown'};

% The non-words to use
non_words = {'nw1', 'nw2','nw3', 'nw4', 'nw5', 'nw6'};

% The initial nouns to use.
% NOTE: To create the stim lists appropriately
% these must be the first 6 words in the 
% following shapes list.
first_words = {'Cane','Disc','Fork',...
    'Lamp','Bone','Heart'};

% The shapes to use
shapes = {'Cane','Disc','Fork','Lamp','Bone','Heart',...
	'Bow','Key','Cup','Boat','Plane','Cross','House',...
	'Bag','Lock','Hand','Shoe','Square','Bell',...
    'Flag','Car','Leaf','Note','Star','Tree'};

% The maximum of in a row of any condition
max_repititions = 4;

% The tasks and conditions.


% Set the task order
if task_order == 1
	tasks = {'comp', 'list'};
elseif task_order == 2
	tasks = {'list', 'comp'};
elseif task_order == 3
	tasks = {'comp'};
elseif task_order == 4
	tasks = {'list'};
else
	error('Bad task order. Exiting...');
end

% Set the modality order
if mod_order == 1
	mods = {'visual', 'audio'};
elseif mod_order == 2
	mods = {'audio', 'visual'};
elseif mod_order == 3
	mods = {'visual'};
elseif mod_order == 4
	mods = {'audio'};
else
	error('Bad modality order. Exiting...');
end

% The conditions have the condition labels, followed
% by the fixation, initial, and critical triggers.
% Lastly, there are the matching and non-matching
% response triggers.
conditions = {};
conditions{1} = {'V_Comp', [1 2 3], [4 5]};
conditions{2} = {'V_Non', [6 7 8], [9 10]};
conditions{3} = {'V_List', [11 12 13], [14 15]};
conditions{4} = {'V_Non_2', [16 17 18], [19 20]};
conditions{5} = {'A_Comp', [21 22 23], [24 25]};
conditions{6} = {'A_Non', [26 27 28], [29 30]};
conditions{7} = {'A_List', [31 32 33], [34 35]};
conditions{8} = {'A_Non_2', [36 37 38], [39 40]};
blink_trigger = 1;

% How much practice to make
max_practice_trials = 20;

% Number of blocks to split the stimuli into
num_blocks = 5;

% The number of times through. 
% NOTE: This will actually be equivalent
% to num_reps*2[match/nomatch]*length(shapes) trials for
% each list, to do all the requisite matching.
num_reps = 2;

% ITI parameters
ITI_mean = .5;
ITI_std = .1;

% Number of blink trials at end
num_blinks = 30;

% The number of different target tokens we have
num_targets = 3;

% Create the new stimulus files
if create_stim_lists
	createStimLists(subject, {'comp','list'}, {'visual','audio'}, conditions, max_repititions, ...
		colors, non_words, first_words, shapes, num_targets, ...
		num_reps, ITI_mean, ITI_std, num_blocks, max_practice_trials)
end

% Picture placement parameters. 
global GL_vertical_offset;
GL_vertical_offset = -100;

% Display timing for the visual modality
global GL_V_fixation_time;
GL_V_fixation_time = 0.300;
global GL_V_ISI_1;
GL_V_ISI_1 = 0.300;
global GL_V_stim_1_time;
GL_V_stim_1_time = 0.300;
global GL_V_ISI_2;
GL_V_ISI_2 = 0.300;
global GL_V_stim_2_time;
GL_V_stim_2_time = 0.300;
global GL_V_ISI_3;
GL_V_ISI_3 = 0.300;

% Display timing for audio modality
global GL_A_fixation_time;
GL_A_fixation_time = 0.300;
global GL_A_ISI_1;
GL_A_ISI_1 = 0.300;
global GL_A_stim_1_time;
GL_A_stim_1_time = 0.600;
global GL_A_ISI_2;
GL_A_ISI_2 = 0.300;
global GL_A_stim_2_time;
GL_A_stim_2_time = 0.700;
global GL_A_ISI_3;
GL_A_ISI_3 = 0.300;
feedback_time = 1;

% Response keys
global GL_same_key;
global GL_different_key;
if strcmp(collection_type, 'Char')
	GL_same_key = '2';
	GL_different_key = '1';
else
	GL_same_key = '2@';
	GL_different_key = '1!';	
end

% To account for a delay in the projector.
global GL_V_trigger_delay;
GL_V_trigger_delay = 0.006;
global GL_A_trigger_delay;
GL_A_trigger_delay = 0.006;

% Set the appropriate parameters
if is_outside
	give_feedback = 1;
	num_practice_trials = num_practice_1;
else	
	num_practice_trials = num_practice_2;
	give_feedback = 0;
end

% These are for picture  placements.
global PTBScreenRes;
global GL_picture_position;
global PTBLastKeyPressTime;

% Let's try our experiment. This try block
% is necessary in order to gracefully exit
% when psychtoolbox crashes. If you keep
% anything from this script, keep this (and
% the paired 'catch' block below.
try

    % First, prepare everything to go. 
	% This call sets all the relevant parameters
	% for PTBWrapper and needs to be called
	% before any Display functions
    PTBSetupExperiment('SampleExperiment');

	% What follows is essentially just the logic for putting
	% the experiment together. Despite its apparent complexity,
	% it is really just reading in stim files and calling performTrial
	% with the appropriate stimuli. The practice does show
	% how to handle feedback. For a sample trial structure,
	% scroll down to performTrial.
	
	% Set the positions now.
	GL_picture_position = [PTBScreenRes.width/2, PTBScreenRes.height/2 + GL_vertical_offset];
	
    % This gives time to get the program up and going.
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');

	% Two tasks
	for t = start_task:length(tasks)
		
		% Set the instructions
		if strcmp(tasks{t},'list')
			instructions = 'If the picture matches any of the words,';
		else
			instructions = 'If the picture matches all of the words,';			
		end
		
		% Two modalities
		for m = start_mod:length(mods)


			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Do the practice first
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			if num_practice_trials > 0

				% Might be giving feedback
				for feedback = give_feedback:-1:0

					% Change the input, if necessary
					if ~is_outside        
						PTBSetInputDevice(button_box_id);
					end

					% Give a screen
					paragraph = {'The practice is about to begin.', ...
						instructions, 'Respond with your index finger.',...
						'If the picture does not match the preceding stimuli',...
						'Respond with your middle finger.', ' ',};
					if feedback
						paragraph{end+1} = 'You will receive feedback';
					else
						paragraph{end+1} = 'You will not receive feedback';
					end
					paragraph{end+1} = 'Press any key to begin.';
					PTBDisplayParagraph(paragraph, {'center', 30}, {'any'});

					% Get the initial start time
					PTBDisplayBlank({.5},'');
					start_time = PTBLastKeyPressTime + .5;

					% Read through each trial
					fid = fopen([subject '_' mods{m} '_' tasks{t} '_practice_' num2str(feedback+1) '.txt']);
					for i = 1:num_practice_trials

						% Parse the next one
						line = fgetl(fid);
						[condition item_num stim_1 stim_2 target ITI f_trig i_trig c_trig t_trig answer] = ...
							strread(line,'%s%f%s%s%s%f%f%f%f%f%s');
						
						% PTBSetLogAppend allows you to write whatever you would like to the
						% output files. The arguments will follow the standard output (e.g. RT, etc.)
						% in each output line.
						PTBSetLogAppend(1,'clear',{'practice', condition{1}, num2str(item_num), ...
							stim_1{1}, stim_2{1}, target{1}, answer{1}});
						[response start_time] = performTrial(start_time, mods{m}, stim_1{1}, stim_2{1},...
							target{1}, ITI, f_trig, i_trig, c_trig, t_trig);

						% Give some feedback, if we want
						if feedback
							if (strcmp(answer{1},'Match') && strcmpi(response, GL_same_key)) ||...
									(strcmp(answer{1},'NoMatch') && strcmpi(response, GL_different_key))
								PTBDisplayText('Correct!', {'center',[0 GL_vertical_offset]},{feedback_time});
							else
								PTBDisplayText('Incorrect.', {'center',[0 GL_vertical_offset]},{feedback_time});
							end
							PTBDisplayBlank({.5},'');
							start_time = start_time + feedback_time + 0.5;
						end
					end
					fclose(fid);

					% Set less for second time
					num_practice_trials = num_practice_2;

					% Give a screen, if done.
					if feedback == 0
						PTBDisplayParagraph({'The practice is now over.', 'Press any key to continue'}, {'center', 30}, {'any'});
					end
					PTBDisplayBlank({.5},'');
				end

				% Change the input, if necessary
				if ~is_outside        
					PTBSetInputDevice(keyboard_id);
				end
			end

			% End here, if outside
			if is_outside
				PTBCleanupExperiment;
				return;
			end

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Do the experiment 
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			% Start the triggers. In order to trigger using the button box in 
			% Mac, this is necessary to call first. It will give a warning if something
			% goes wrong, but allow the script to continue.
			PTBInitUSBBox;

			% Time to start the recording
			PTBDisplayParagraph({'Please lie still as we start the recording.'}, {'center', 30}, {'a'});
			paragraph = {'The experiment is about to begin.', ...
				instructions, 'Respond with your index finger.',...
				'If the picture does not match the preceding stimuli',...
				'Respond with your middle finger.', ' ','Press any key to begin.'};
			PTBDisplayParagraph(paragraph, {'center', 30}, {'any'});

			% Change the input, if necessary
			if ~is_outside        
				PTBSetInputDevice(button_box_id);
			end

			% Go through each block
			for i = start_block:num_blocks

				% Give a screen
				PTBDisplayParagraph({['Block number ' num2str(i) ' is about to begin.'], 'Press any key to begin.'}, {'center', 30}, {'any'});

				% Get the initial start time
				PTBDisplayBlank({.5},'');
				start_time = PTBLastKeyPressTime + .5;

				% Read through each trial
				fid = fopen([subject '_' mods{m} '_' tasks{t} '_stim_' num2str(i) '.txt']);
				while 1
					line = fgetl(fid);
					if ~ischar(line)
						break;
					end

					% Parse the next one
					[condition item_num stim_1 stim_2 target ITI f_trig i_trig c_trig t_trig answer] = ...
						strread(line,'%s%f%s%s%s%f%f%f%f%f%s');
					PTBSetLogAppend(1,'clear',{'experiment', condition{1}, num2str(item_num), ...
						stim_1{1}, stim_2{1}, target{1}, answer{1}});
					[response start_time] = performTrial(start_time, mods{m}, stim_1{1}, stim_2{1},...
						target{1}, ITI, f_trig, i_trig, c_trig, t_trig);
				end
				fclose(fid);

				% Give a screen
				PTBDisplayParagraph({['Block ' num2str(i)  ' of ' num2str(num_blocks) ' is now over.'], 'Press any key to continue.'}, {'center', 30}, {'any'});
				PTBDisplayBlank({.5},'');
			end
			
		% Change the input, if necessary
		if ~is_outside        
			PTBSetInputDevice(keyboard_id);
		end

		% The end screens 
		PTBDisplayParagraph({['Part ' num2str(m) ' is now over.'],'Please lie still as we save the data.'},...
			{'center', 30}, {'a'});

		% Quick blank to make sure the last screen stays on
		PTBDisplayBlank({.1},'');

		% Reset to go through the practice, if necessary	
		give_feedback = 1;
		num_practice_trials = num_practice_1;
		end

	% The end screens
	PTBDisplayParagraph({['Task ' num2str(t) ' is now over.']},...
		{'center', 30}, {'a'});
	end
	
    % Time to start the recording
	paragraph = {'A quick blink block is about to begin.','Just blink naturally when the cross disappears.'};
	PTBDisplayParagraph(paragraph, {'center', 30}, {'a'});

	% Do the blink block
	for i = 1:num_blinks
		performBlinkTrial(blink_trigger); 
	end

	% And done
	paragraph = {'The experiment is now over.','We will be in shortly.'};
	PTBDisplayParagraph(paragraph, {'center', 30}, {'a'});

	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch
	PTBHandleError;
end


% Helper Functions

% Show one trial. This function gives a sample trial structure. The first return
% value is the response key pressed at the end of the trial. This is useful for
% feedback during the experiment, etc. 
%
% IMPORTANT: There is some added complexity from the 'start_time' and 'end_time' parameters.
% Basically, PTBWrapper allows for two different kinds of durations for each event,
% either relative timing or absolute timing. Relative timing is conceptually easier, it
% simply involves giving the appropriate duration of the stimulus (e.g. .3 (sec)). However,
% this has the tendency to drift a little. For the most accurate timing, you can give an absolute
% duration (i.e. a raw system time). Thus, any drift is compensated for at each stimuli, and so
% the timing is much better. However, this method is tempermental, as an incorrect 
% duration will just cause the program to hang. Therefore, I would recommend using
% relative timing during testing and then switching over to absolute timing once
% everything is set.
function [response end_time] = performTrial(start_time, modality, initial_stim, ...
	critical_stim, target_stim, ITI, f_trig, i_trig, c_trig, t_trig)

% Trial parameters. I find it easier to set these at the top of 
% the file and then declare and use them down here.
global GL_picture_position;
global GL_same_key;
global GL_different_key;
global GL_vertical_offset;

% The visual parameters
global GL_V_fixation_time;
global GL_V_ISI_1;
global GL_V_stim_1_time;
global GL_V_ISI_2;
global GL_V_stim_2_time;
global GL_V_ISI_3;
global GL_V_trigger_delay;

% The auditory parameters
global GL_A_fixation_time;
global GL_A_ISI_1;
global GL_A_stim_1_time;
global GL_A_ISI_2;
global GL_A_stim_2_time;
global GL_A_ISI_3;
global GL_A_trigger_delay;


% Show a cross first
if strcmp(modality,'visual')
	end_time = start_time + GL_V_fixation_time;
else
	end_time = start_time + GL_A_fixation_time;
end

% Please see the comments at the top of each Display 
% file for a complete explanation of the various arguments.
% Here they are, the text to display, where to display it, for 
% how long, an MEG trigger value to send, and a short
% delay to have that trigger match the timing of the presentation.
PTBDisplayText('+', {'center', [0 GL_vertical_offset]},{end_time}, f_trig, GL_V_trigger_delay);

% Then a blank
if strcmp(modality,'visual')
	end_time = end_time + GL_V_ISI_1;
	PTBDisplayBlank({end_time},'ISI');
else
	end_time = end_time + GL_A_ISI_1;
	PTBDisplayText('+', {'center',[0 GL_vertical_offset]},{end_time});
end

% Initial stimulus
if strcmp(modality,'visual')
	end_time = end_time + GL_V_stim_1_time;
	PTBDisplayPictures({initial_stim},{GL_picture_position},{1},{end_time},'Initial', i_trig, GL_V_trigger_delay);
else
	end_time = end_time + GL_A_stim_1_time;
	PTBDisplayText('+',{'center', [0 GL_vertical_offset]}, {-1});
	PTBPlaySoundFile(initial_stim, {end_time}, i_trig, GL_A_trigger_delay);
end

% Then a blank
if strcmp(modality,'visual')
	end_time = end_time + GL_V_ISI_2;
	PTBDisplayBlank({end_time},'ISI_2');
else
	end_time = end_time + GL_A_ISI_2;
	PTBDisplayText('+', {'center',[0 GL_vertical_offset]},{end_time});
end

% The second stimulus
if strcmp(modality,'visual')
	end_time = end_time + GL_V_stim_2_time;
	PTBDisplayPictures({critical_stim},{GL_picture_position},{1},{end_time},'Critical', c_trig, GL_V_trigger_delay);
else
	end_time = end_time + GL_A_stim_2_time;
	PTBDisplayText('+',{'center', [0 GL_vertical_offset]}, {-1});
	PTBPlaySoundFile(critical_stim, {end_time}, c_trig, GL_A_trigger_delay);
end

% Then a blank
if strcmp(modality,'visual')
	end_time = end_time + GL_V_ISI_3;
	PTBDisplayBlank({end_time},'ISI_3');
else
	end_time = end_time + GL_A_ISI_3;
	PTBDisplayText('+', {'center',[0 GL_vertical_offset]},{end_time});
end

% And the target
PTBDisplayPictures({target_stim},{GL_picture_position},...
    {1},{GL_same_key, GL_different_key},'Target', t_trig, GL_V_trigger_delay);

% Quick screen to get the response time.
% IMPORTANT: Due to the way displays are batched,
% the response from a key press is not available until
% a subsequent display has been processed. Therefore,
% A short screen like the following is necessary in order
% to accurately get the PTBLastKeyPress and PTBLastKeyPressTime
% parameters.
PTBDisplayBlank({.1},'Response_Catcher');
global PTBLastKeyPressTime;

% And the final blank
end_time = PTBLastKeyPressTime + .1 + ITI;
PTBDisplayBlank({end_time},'ITI');

% Record the response
global PTBLastKeyPress;
response = PTBLastKeyPress;


% Make people blink
function performBlinkTrial(b_trigger)

% Put the cross on and off
global GL_vertical_offset;
PTBDisplayText('+',{'center', [0 GL_vertical_offset]}, {1});
PTBDisplayBlank({1}, 'Blink_Break', b_trigger);

