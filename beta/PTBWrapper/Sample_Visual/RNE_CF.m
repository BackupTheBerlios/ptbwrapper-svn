%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: RNE_CF.m
%
% Runs a rapid enumeration script. 
% NOTE: This script is set to automatically create new stimulus files to use.
%
% Args:
%	- subject: The subject id, can be any string.
%		* This will be prepended to the log and data files.
%
% Usage: RNE_CF('Subj_Label')
%
% Author: Doug Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RNE_CF(subject)

% Make sure we're compatible
PTBVersionCheck(1,1,0,'at least');

% Set to debug, if we want to.
PTBSetIsDebugging(0);

% The queue doesn't seem to work
% when we're waiting over two screens, so
% disable for now.
PTBSetDisableKbQueue(1);

% Set the exit key.
PTBSetExitKey('ESCAPE');

% Where to write out the logs.
% NOTE: Set the keyfile name in order to log all the TRs
PTBSetLogFiles([subject '_log.txt'], [subject '_data.txt']);


% Experiment parameters

% Number of repetitions through the complete set
% of conditions.
% This will create num_reps*length(set_sizes)*length(separations)*2*2
% The last 2s are: 
%	- smaller / larger number first
%	- first / second display connected
num_reps = 3;

% Number of blocks to use.
% NOTE: The number of trials does not
% need to be divisible by this number.
num_blocks = 5;

% Number of practice trials
num_practice_trials = 20;

% The different separation values
% NOTE: The last separation value
% serves as the "unconnected" control.
% These values are how far we rotate
% each line segment away from connected.
separations = [0 2 7 22 50];

% The different set size pairs.
% Each 
set_sizes = {[6 8], [10 14], [20 26], [32 40]};

% Control of the ITIs
ITI_mean = 0.500;
ITI_std = 0.100;


% Diameter in pixels of the dots
global GL_dot_size;
GL_dot_size = 15;

% For changing the pattern of the dots
global GL_pattern_width;
GL_pattern_width = 10;

% The width of the connecting lines
global GL_line_width;
GL_line_width = 1;

% How far from the edge of the cells 
% we keep the dots
global GL_cell_buffer;
GL_cell_buffer = 20;

% How far from the edge of the screen we want anything
global GL_screen_buffer;
GL_screen_buffer = 30;

% Smallest separation allowed between dots.
global GL_min_separation;
GL_min_separation = 25;

% Largest separation allowed between dots.
global GL_max_separation;
GL_max_separation = 95;

%  Closest that lines can get to 
% vertical or horizontal
global GL_min_rotation;
GL_min_rotation = 5;

% Trial parameters.
global GL_fixation_time;
GL_fixation_time = 0.300;
global GL_ISI;
GL_ISI = 0.150;
global GL_screen_time;
GL_screen_time = 0.450;
global GL_time_out;
GL_time_out = 0.800;
global GL_more_key;
GL_more_key = 'm';
global GL_less_key;
GL_less_key = 'l';

% First, make the stim lists
disp('Creating stim lists...');
createRNEStimLists(separations, set_sizes, num_reps, num_blocks, ITI_mean, ITI_std, num_practice_trials);
disp('Done.');

% Define the stimulus lists to use
stim_lists = {'practice_list.txt'};
for i = 1:num_blocks
	stim_lists{i+1} = ['stim_list_' num2str(i) '.txt'];
end

% Set the background color to gray
PTBSetBackgroundColor(0);

% Don't use the start screen for now
PTBSetUseStartScreen(1);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5)
%Screen('Preference', 'SkipSyncTests', 1);

% Have to make the textured circle ourselves
% Otherwise, can just use PTBDrawDots...
global GL_dot_matrices;
num_dots = 10;
GL_dot_matrices = {};
for i = 1:num_dots
	GL_dot_matrices{i} = createDotMatrix;
end

% Let's try our experiment
try

    % First, prepare everything to go
    PTBSetupExperiment('RNE_CF');
	PTBDisplayParagraph({'The experiment is about to begin.', 'Press any key to begin.'}, {'center', 30}, {'any'});
	
	% This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');
	
	% Show each stimulus list
	% NOTE: First one is practice
 	for i = 1:length(stim_lists)

		% Show the start of the block
		if i == 1
			PTBDisplayParagraph({['The practice is about to begin.'], 'Press any key to begin.'}, {'center', 30}, {'any'});
			b_label = 'practice';
		else
			PTBDisplayParagraph({['Block ' num2str(i-1) ' of ' num2str(length(stim_lists)-1) ' is about to begin.'], 'Press any key to begin.'}, {'center', 30}, {'any'});
			b_label = 'experiment';
		end
		
		fid = fopen(stim_lists{i});
		while 1
			line = fgetl(fid);
			if ~ischar(line)
				break;
			end
			
			% Read in the next trial
			[item_num num_dots_1 sep_1 num_dots_2 sep_2 ITI set_size separation fewer connected] = strread(line,'%f%f%f%f%f%f%f%f%f%f');
			PTBSetLogAppend(1,'clear',{num2str(item_num), num2str(num_dots_1), num2str(sep_1), num2str(num_dots_2), num2str(sep_2), ...
				num2str(set_size), num2str(separation), num2str(fewer), num2str(connected), b_label});
			performTrial(num_dots_1, sep_1, num_dots_2, sep_2, ITI);
		end
		fclose(fid);
		
		% Show the end of the block
		if i == 1
			PTBDisplayParagraph({['The practice is now over.'], 'Press any key to continue.'}, {'center', 30}, {'any'});
		else
			PTBDisplayParagraph({['Block ' num2str(i-1) ' of ' num2str(length(stim_lists)-1) ' is now over.'], 'Press any key to continue.'}, {'center', 30}, {'any'});
		end
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
function performTrial(num_dots_1, sep_1, num_dots_2, sep_2, ITI)

% The trial parameters, set at top
global GL_dot_matrices;
global GL_line_width;
global GL_fixation_time;
global GL_ISI;
global GL_screen_time;
global GL_time_out;
global GL_more_key;
global GL_less_key;
global PTBLastKeyPress;

% Show a cross first
PTBDisplayText('+',{'center'},{GL_fixation_time});	

% Then a blank
PTBDisplayBlank({GL_ISI},'');

% Get the positions
[d_positions l_positions] = calculatePositions(num_dots_1, sep_1);

% Set the first dots
dots = {};
for i = 1:num_dots_1
	dots{i} = GL_dot_matrices{ceil(rand*length(GL_dot_matrices))};
end

% The first screen
PTBDisplayLines(l_positions, GL_line_width, {-1})
PTBDisplayMatrices(dots,d_positions,{GL_screen_time},'First Screen');

% Then a blank
PTBDisplayBlank({GL_ISI},'');

% Get the positions
[d_positions l_positions] = calculatePositions(num_dots_2, sep_2);

% Set the second dots
dots = {};
for i = 1:num_dots_2
	dots{i} = GL_dot_matrices{ceil(rand*length(GL_dot_matrices))};
end

% We want to allow key presses over the next 
% couple of screens...
global PTBDisableTimeOut;
PTBDisableTimeOut = 1;

% The second screen.
PTBDisplayLines(l_positions, GL_line_width, {-1})
PTBDisplayMatrices(dots,d_positions,{GL_screen_time, GL_more_key, GL_less_key},'Trial');

% Then a mask
num_mask_dots = 300;
[d_positions l_positions] = makeMask(num_mask_dots);
dots = {};
for i = 1:num_mask_dots
	dots{i} = GL_dot_matrices{ceil(rand*length(GL_dot_matrices))};
end
PTBDisplayLines(l_positions, GL_line_width, {-1}, 'Trial','TIMEOUT')
PTBDisplayMatrices(dots,d_positions,{GL_time_out, GL_more_key, GL_less_key},'Trial','TIMEOUT');
	
% This should clear the last response
PTBDisplayBlank({.1},'Trial');

% Want to time out now
% TODO: Allow this to occur earlier.
PTBDisableTimeOut = 0;

% Prompt if responded too slowly
if strcmp(PTBLastKeyPress, 'TIMEOUT')
	PTBDisplayText('Please respond faster.',{'center'},{2},'TIMEOUT');
	PTBDisplayText('Please respond faster.',{'center'},{'any'},'TIMEOUT');
end

% And wait for the ITI to end.
PTBDisplayBlank({ITI},'');


% Helper to place the dots and lines
function [d_positions l_positions] = calculatePositions(num_dots, separation)

% Get the cells to use
cells = calculateCells(num_dots/2);

% Put each pair in a random cell
p = randperm(length(cells));
for i = 1:num_dots/2
	[d_positions{2*i-1} d_positions{2*i} l_positions(:,4*i-3:4*i)] = placeDotPair(cells{p(i)}, separation);
end


% Quick helper to make the mask
function [d_positions l_positions] = makeMask(num_mask_dots)

global PTBScreenRes;
global GL_screen_buffer;
global GL_min_separation;
global GL_max_separation

% Just place randomly
d_positions = {};
for i = 1:num_mask_dots
	d_positions{i} = [floor((PTBScreenRes.width-2*GL_screen_buffer)*rand)+GL_screen_buffer ...
		floor((PTBScreenRes.height-2*GL_screen_buffer)*rand)+GL_screen_buffer];
end

avg_sep = (GL_max_separation + GL_min_separation) / 2;
l_positions = [];
for i = 1:num_mask_dots/2
	l_positions(1:2,2*i-1) = [floor((PTBScreenRes.width-2*GL_screen_buffer)*rand)+GL_screen_buffer ...
		floor((PTBScreenRes.height-2*GL_screen_buffer)*rand)+GL_screen_buffer];
	l_positions(1:2,2*i) = [l_positions(1,2*i-1) + randn*avg_sep l_positions(2,2*i-1) + randn*avg_sep];
end

% Help to place within a cell
% positions should be [x1 y1; x2 y2]'
function [d1_position d2_position l_positions] = placeDotPair(cell, separation)

% Stimuli parameters, set at top
global GL_dot_size;
global GL_cell_buffer;
global GL_min_separation;
global GL_max_separation;
global GL_min_rotation;

% Need a min and max
min_dist = GL_min_separation + GL_dot_size;

% First get the most possible..
max_dist = min(cell(2)-cell(1), cell(4)-cell(3)) - GL_dot_size - GL_cell_buffer;

% And make sure it's not bigger than we want
max_dist = min(GL_max_separation + GL_dot_size, max_dist);

% And a distance
% TODO: Maybe use a non-uniform distribution.
dist = rand*(max_dist-min_dist) + min_dist;

% Grab the center
center = [((cell(2) - cell(1))/2) + cell(1), ((cell(4) - cell(3))/2) + cell(3)];

% Set the initial dot points
d1 = [dist/2 0];
d2 = [-dist/2 0];

% And the initial line points
l1 = [d1(1) - GL_dot_size/2 0];
l2 = [0 0];
l3 = [0 0];
l4 = [d2(1) + GL_dot_size/2 0];

% Separate them
[l1 l2 l3 l4] = separateLines(separation,l1,l2,l3,l4);

% Rotate around the center
min_angle = GL_min_rotation;
max_angle = 90 - GL_min_rotation;
rot = rand*(max_angle-min_angle) + min_angle;
if rand < 0.5
	rot = rot+90;
end

% Rotate
d1 = rotatePoint(d1,rot);
d2 = rotatePoint(d2,rot);
l1 = rotatePoint(l1,rot);
l2 = rotatePoint(l2,rot);
l3 = rotatePoint(l3,rot);
l4 = rotatePoint(l4,rot);

% Now, move the center
c_rot = rand*360;
m_dist = (max_dist - dist);
center(1) = center(1) + cosd(c_rot)*m_dist/2;
center(2) = center(2) + sind(c_rot)*m_dist/2;

% And set the positions [x1 y1; x2 y2]'
d1_position = d1 + center; 
d2_position = d2 + center;
l_positions = [l1 + center; l2 + center; l3 + center; l4 + center]';


% Helper to separate.
function [l1 l2 l3 l4] = separateLines(separation, l1,l2,l3,l4)

% And the initial line points
x1 = l1(1);
x2 = l4(1);

% Translate for rotation
l1(1) = l1(1) - x1;
l2(1) = l2(1) - x1;
l3(1) = l3(1) - x2;
l4(1) = l4(1) - x2;

% Now, rotate the midpoints as necessary
if rand < 0.5
	separation = separation*-1;
end
l2 = rotatePoint(l2,separation);
l3 = rotatePoint(l3,separation);

% And translate back
l1(1) = l1(1) + x1;
l2(1) = l2(1) + x1;
l3(1) = l3(1) + x2;
l4(1) = l4(1) + x2;


% Quick rotate
function new_p = rotatePoint(p, rot)
new_p = [p(1)*cosd(rot) - p(2)*sind(rot) p(2)*cosd(rot) + p(1)*sind(rot)];


% Helper to get the number cells
% Returns cell entries: [x_min x_max y_min y_max]
function cells = calculateCells(num_dots)

% Using the screen size, minus the buffer
global GL_screen_buffer;
global PTBScreenRes;
actual_width = PTBScreenRes.width - GL_screen_buffer*2;
actual_height = PTBScreenRes.height - GL_screen_buffer*2;
s_ratio = actual_width / actual_height;

% Find the number of rows and columns
rows = 1;
max = 100;
while 1
	if rows > max
		error('Too many dots. Exiting...');
	end
	
	% Find the appropriate number of columns
	columns = floor(s_ratio*rows);
	
	% See if we have enough
	if rows*columns >= num_dots
		break;
	end
	
	% Otherwise, keep going
	rows = rows + 1;
end

% Find the dimensions
c_width = floor(actual_width / columns);
c_height = floor(actual_height / rows);
cells = {};
for i = 1:rows
	for j = 1:columns
		cells{end+1} = [(j-1)*c_width j*c_width (i-1)*c_height i*c_height];
		cells{end} = cells{end} + GL_screen_buffer;
	end
end

% Helper to make the dots
function matrix = createDotMatrix

% Parameters for creation
global GL_dot_size;
global GL_pattern_width;

% Get a random offset
pattern_offset = ceil(rand*GL_pattern_width);

% Create the matrix
matrix = ones(GL_dot_size,GL_dot_size,4)*255;

% Set the outside to be transparent
% TODO: Clearly there's a faster way..
for i = 1:GL_dot_size
	for j = 1:GL_dot_size
		if (i-GL_dot_size/2)*(i-GL_dot_size/2) + (j-GL_dot_size/2)*(j-GL_dot_size/2) > GL_dot_size/2*GL_dot_size/2
			matrix(i,j,4) = 0;
		else
			m_i = mod(i+pattern_offset,GL_pattern_width);
			m_j = mod(j+pattern_offset,GL_pattern_width);
			if (m_i < GL_pattern_width/2 && m_j < GL_pattern_width/2) || (m_i > GL_pattern_width/2 && m_j > GL_pattern_width/2)
				matrix(i,j,1:3) = 0;
			end
		end
	end
end


