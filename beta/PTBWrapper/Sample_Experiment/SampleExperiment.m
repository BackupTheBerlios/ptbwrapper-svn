%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: SampleExperiment.m
%
% A sample face presentation script. This will present pairs of faces and masks, alternating
% sides. Occasionally, two gabors will follow. It's setup to have the subject press '2' if 
% the gabors are facing the same way, and '1' if not. 
%
% NOTE: This is setup to be run in an MEG machine, with triggers, etc. If that's not your 
% setup just ignore the 'no trigger' warning at the beginning. Also, to get past the
% "start the recording" screen, hit 'a'.
%
% Args:
%	- subject: The subject id, can be any string.
%		* This will be prepended to the log and data files.
%	- is_outside: Enter 1 if you're outside the MEG machine (Optional).
%
% NOTE: This will recreate the stimulus lists every time.
%
% Usage: SampleExperiment('Subj_Label')
%
% Author: Doug Bemis
% Date: 4/12/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SampleExperiment(subject, is_outside)

% Parse the arguments
if nargin < 2
	is_outside = 0;
end

% Need to change inputs for MEG...
% NOTE: Might need to switch these - depends on 
% the USB ports, etc....
keyboard_id = 2;
button_box_id = 1;

% Can use this command to check for compatibility.
PTBVersionCheck(1,1,5,'at least');

% Set to debug, if we want to.
% This will make the screen smaller and
% enable you to get back to MATLAB, when necessary.
PTBSetIsDebugging(0);

% Set the exit key. Entering this key as a response
% will exit the program.
PTBSetExitKey('ESCAPE');

% Where to write out the logs.
PTBSetLogFiles([subject '_log.txt'], [subject '_data.txt']);


% Experiment parameters

% The conditions
conditions = {'left','right'};

% The condition triggers
triggers = [1, 2];

% How much practice
num_practice_trials = 20;

% Number of blocks to split the stimuli into
num_blocks = 3;

% Number of times through each condition
num_cond_reps = 132;

% Percentage of trials with decisions
decisions_percent = .3;

% Tilt of the gabors, in degrees
gabor_tilt = 45;

% ITI parameters
ITI_mean = .75;
ITI_std = .15;

% List of picture names
picture_folder = 'Pictures';
pictures = {'pic_Zoe','pic_Veronica','pic_Tina','pic_Shaul','pic_Prof',...
	'pic_Monica','pic_Marika','pic_Joe','pic_Grad2','pic_Grad1','pic_Ed','pic_Doug'};

% Create the new stimulus files
createStimLists(conditions, triggers, pictures, picture_folder, ...
    num_practice_trials, num_blocks, num_cond_reps, decisions_percent, ...
   gabor_tilt, ITI_mean, ITI_std);


% The size of the gabors
global GL_gabor_size;
GL_gabor_size = 275;

% The contrast for the gabors
global GL_gabor_contrast;
GL_gabor_contrast = 200;

% Picture and Gabor placement parameters. 
global GL_vertical_offset;
GL_vertical_offset = -100;
global GL_picture_spacing;
GL_picture_spacing = 250;
global GL_gabor_spacing;
GL_gabor_spacing = 250;

% Display timing
global GL_fixation_time;
GL_fixation_time = .5;
global GL_face_time;
GL_face_time = .2;
global GL_gabor_time;
GL_gabor_time = .2;

% Between fixation cross and faces
global GL_ISI_1
GL_ISI_1 = 0;

% Between faces and gabors
global GL_ISI_2
GL_ISI_2 = 0;

% Response keys
global GL_same_key;
global GL_different_key;
GL_same_key = '2@';
GL_different_key = '1!';	

% Trigger is a little fast
global GL_trigger_delay;
GL_trigger_delay = 0.015;

% Don't use the start screen for now
PTBSetUseStartScreen(1);

% Use gray
PTBSetBackgroundColor([127 127 127]);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5)
%Screen('Preference', 'SkipSyncTests', 1);

% These are for picture and gabor placements.
global PTBScreenRes;
global GL_picture_positions;
global GL_gabor_positions;

% Let's try our experiment
try

    % First, prepare everything to go
    PTBSetupExperiment('CN_Faces');

	% Set the positions now
	GL_picture_positions = {[PTBScreenRes.width/2 - GL_picture_spacing/2, PTBScreenRes.height/2 + GL_vertical_offset],...
        [PTBScreenRes.width/2 + GL_picture_spacing/2, PTBScreenRes.height/2 + GL_vertical_offset]};
	GL_gabor_positions = {[PTBScreenRes.width/2 - GL_gabor_spacing/2, PTBScreenRes.height/2 + GL_vertical_offset],...
        [PTBScreenRes.width/2 + GL_gabor_spacing/2, PTBScreenRes.height/2 + GL_vertical_offset]};
    
    % Start the triggers
	PTBInitUSBBox;
	
	% This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Do the practice first
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if num_practice_trials > 0
        
        % Change the input, if necessary
        if ~is_outside        
	        PTBSetInputDevice(button_box_id);
        end
        
        % Give a screen
		PTBDisplayParagraph({'The practice is about to begin.', 'If the lines are oriented in the same way.', 'Respond with your index finger.',...
			'If the lines are oriented in different directions.', 'Respond with your middle finger.', ' ', 'Press any key to begin.'}, {'center', 30}, {'any'});
		PTBDisplayBlank({.5},'');

		% Read through each trial
		fid = fopen('practice_list.txt');
		while 1
			line = fgetl(fid);
			if ~ischar(line)
				break;
			end

			% Parse the next one
			[condition item_num pic_1 pic_2 ITI trigger decision tilts(1) tilts(2)] = ...
				strread(line,'%s%f%s%s%f%f%s%f%f');
			PTBSetLogAppend(1,'clear',{'practice', condition{1}, num2str(item_num), pic_1{1}, pic_2{1}, ...
				decision{1}, num2str(tilts(1)), num2str(tilts(2))});
			response = performTrial(pic_1{1}, pic_2{1}, decision{1}, tilts, ITI, trigger);

			% Give some feedback
            if strcmpi(decision{1}, 'decision')
                if (tilts(1) == tilts(2) && strcmpi(response, GL_same_key)) ||...
                        (tilts(1) ~= tilts(2) && strcmpi(response, GL_different_key))
                    PTBDisplayText('Correct!', {'center',[0 GL_vertical_offset]},{1});
                else
                    PTBDisplayText('Incorrect.', {'center',[0 GL_vertical_offset]},{1});
                end
                PTBDisplayBlank({.5},'');
            end		
		end
		fclose(fid);
      
		% Give a screen
		PTBDisplayParagraph({'The practice is now over.'}, {'center', 30}, {'any'});
        PTBDisplayBlank({.5},'');
  
        % Change the input, if necessary
        if ~is_outside        
            PTBSetInputDevice(keyboard_id);
        end
    end
            
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Do the experiment 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% Time to start the recording
	PTBDisplayParagraph({'Please lie still as we start the recording.'}, {'center', 30}, {'a'});
	PTBDisplayParagraph({'The experiment is about to begin.', 'If the lines are oriented in the same way.', 'Respond with your index finger.',...
		'If the lines are oriented in different directions.', 'Respond with your middle finger.', ' ', 'Press any key to begin.'}, {'center', 30}, {'any'});

    % Change the input, if necessary
    if ~is_outside        
        PTBSetInputDevice(button_box_id);
    end
    
    % Go through each block
	for i = 1:num_blocks
		
		% Give a screen
		PTBDisplayParagraph({['Block number ' num2str(i) ' is about to begin.'], 'Press any key to begin.'}, {'center', 30}, {'any'});
		PTBDisplayBlank({.5},'');
		
		% Read through each trial
		fid = fopen(['stim_list_' num2str(i) '.txt']);
		while 1
			line = fgetl(fid);
			if ~ischar(line)
				break;
			end

			% Parse the next one
			[condition item_num pic_1 pic_2 ITI trigger decision tilts(1) tilts(2)]...
                = strread(line,'%s%f%s%s%f%f%s%f%f');
			PTBSetLogAppend(1,'clear',{'experiment', condition{1}, num2str(item_num), pic_1{1}, pic_2{1}, ...
				decision{1}, num2str(tilts(1)), num2str(tilts(2))});
			performTrial(pic_1{1}, pic_2{1}, decision{1}, tilts, ITI, trigger);
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
	PTBDisplayText('The experiment is now over.',{'center'},{'any'});	

	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
	
	% And finish up
    PTBCleanupExperiment;

catch
	PTBHandleError;
end


% Helper Functions

% Show one trial
function response = performTrial(pic_1, pic_2, decision, tilts, ITI, trigger)

% Trial parameters
global GL_gabor_size;
global GL_gabor_positions;
global GL_picture_positions;
global GL_fixation_time;
global GL_face_time;
global GL_ISI_1
global GL_ISI_2
global GL_gabor_time;
global GL_same_key;
global GL_different_key;
global GL_trigger_delay;
global GL_gabor_contrast;
global GL_vertical_offset;

% Show a cross first
PTBDisplayText('+',{'center',[0 GL_vertical_offset]}, {GL_fixation_time});	

% Then a blank, if needed
if GL_ISI_1 > 0
	PTBDisplayBlank({GL_ISI_1},'ISI');
end

% Show the faces
PTBDisplayPictures({pic_1, pic_2}, GL_picture_positions, {1,1}, ...
    {GL_face_time}, 'faces', trigger, GL_trigger_delay);

% Might have a decision
global PTBDisableTimeOut;
global PTBLastKeyPress;
response = '';
if strcmpi(decision, 'decision')
	
	% We want to allow key presses over the next 
	% couple of screens...
	PTBDisableTimeOut = 1;

	% Show the gabors
	if GL_ISI_2 > 0
		PTBDisplayBlank({GL_ISI_2},'Decision_ISI');
	end
	PTBDisplayGabors({[GL_gabor_size GL_gabor_size], [GL_gabor_size GL_gabor_size]},...
        GL_gabor_positions, tilts, [GL_gabor_contrast GL_gabor_contrast], {GL_gabor_time, GL_same_key, GL_different_key},'Decision');

	% Then a blank, until a response, only if we didn't get one before
	PTBDisplayBlank({GL_same_key, GL_different_key},'Decision', 'TIMEOUT');
	
	% This should clear the last response, etc...
	PTBDisplayBlank({.1},'Decision_ISI');

	% Want to time out now
	% TODO: Allow this to occur earlier.
	PTBDisableTimeOut = 0;
	response = PTBLastKeyPress;
end

% And the final blank
PTBDisplayBlank({ITI},'ITI');


