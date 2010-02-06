%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: generateControlLists_fMRI.m
%
% Generate the stimuli lists for the
% visual modification experiment.
%
% This ensures that the same stimuli
% are used for modified and unmodified nouns.
% And the same stimuli are used for the
% match and nomatch targets.
%
% Also, the randomization is done here.
%
%	- run_lists: Output from optseq with the trial ordering
%		for each run.
%
% NOTE: Optseq usage example:
%       optseq: optseq2 --ntp 152 --tr 2 --psdwin 0 20 --ev mod 4 19 
%			--ev non 4 19 --ev fix 4 19 --nkeep 6 --o VMod_1 --nsearch 10000
%       optseq: optseq2 --ntp 144 --tr 2 --psdwin 0 20 --ev mod 4 18 
%			--ev non 4 18 --ev fix 4 18 --nkeep 2 --o VMod_2 --nsearch 10000
%
% Author: Doug Bemis
% Date: 7/23/08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function generateControlLists_fMRI(run_lists)

% Get the ordering first
[total_trials ordering] = getOrdering(run_lists);

% Then, the stim lists
stims = makeStimLists(total_trials);

% And, print them out
counters = ones(1,length(stims));
for i = 1:length(ordering)
	fid = fopen(['stim_' num2str(i) '.txt'],'w');
	for j = 1:length(ordering{i})
		curr_type = ordering{i}{j}(1);
		curr_ITI = num2str(ordering{i}{j}(2));
		fprintf(fid,[stims{curr_type}{counters(curr_type)} '\t' curr_ITI '\n']);
		counters(curr_type) = counters(curr_type) + 1;
	end
	fclose(fid);
end

function [total_trials ordering] = getOrdering(run_lists)

% This is the amount of time between the time 
% out and the next trial
default_ITI = 0.500;

% Load each of the lists
counters = zeros(1,3);
ordering = {};
for i = 1:length(run_lists)
	ordering{i} = {};
	fid = fopen(run_lists{i});
	while 1
		line = fgetl(fid);
		if ~ischar(line)
			break;
		end
		
		% Read the next one
		[start type len one condition] = strread(line,'%f%f%f%f%s'); 
		
		% If it's NULL, add to previous trial
		if type > 0
			ordering{i}{length(ordering{i})+1} = [type default_ITI];
			counters(type) = counters(type) + 1;
		else
			ordering{i}{length(ordering{i})}(2)= ordering{i}{length(ordering{i})}(2) + len;
		end
	end
	fclose(fid);
end

% Check the counts
if sum(diff(counters)) ~= 0
	error('Different number of trials per condition. Exiting...');
end

% And set to return
total_trials = counters(1);

% Make the lists
function stims = makeStimLists(total_trials)

% The colors to use
colors = {'Red','Blue','Pink',...
    'Black','Green','Brown'};

% The shapes to use
shapes = {'Disc','Plane','Bag','Lock','Cane',...
    'Hand','Key','Shoe','Bone','Square','Bell',...
    'Boat','Bow','Car','Cross','Cup','Flag',...
    'Fork','Heart','Lamp','Leaf','Note',...
    'Star','Tree','House'};

fixations = {'s1','s2','s3','s4','s5','s6'};
non_words = {'nw1','nw2','nw3','nw4','nw5','nw6'};


% The number of alternative targets we have
num_targets = 3;

% The number of times through. 
% NOTE: This will actually be equivalent
% to 2*num_reps*length(shapes) trials for
% each list, to do all the requisite matching.
num_reps = ceil(total_trials / (2*length(shapes)));

% Randomize
rand('twister',sum(100*clock))

% First, create the set of targets. There will
% be one set of targets, used for both 
% matching and non-matching, for each list.
% The three fields are:
%   - color
%   - shape
%   - target num
% NOTE: The shapes will stay in order
targets = zeros(num_reps*length(shapes),3);
for i = 1:num_reps
    for j = 1:length(shapes)
        targets((i-1)*length(shapes) + j,:) = [ceil(rand*length(colors)) j ceil(rand*num_targets)];
    end
end

% First, make the modified list:
%   - Fix
%   - Color
%   - Shape
%   - Target
stim = zeros(num_reps*2*length(shapes),6);

% Fill in the targets
stim(1:num_reps*length(shapes),4:6) = targets;
stim(1+num_reps*length(shapes):end,4:6) = targets;

% First half will all be matching
for i = 1:num_reps*length(shapes)
    stim(i,2:3) = stim(i,4:5);
end

% Second half will have half match
% only the shape and half match only the color.
for i = 1:num_reps
    
    % Randomly grab half of them to permute
    num_permute = floor(length(shapes)/2);
    
    % Adjust to make exactly half, if we have an
    % odd number of shapes. Either adding 1 or 
    % none to the floored value.
    if mod(length(shapes),2) == 1
        num_permute = num_permute + mod(i,2);
    end

    % Find which to permute
    to_permute = randperm(length(shapes));
    to_permute = to_permute(1:num_permute);

    % Try permuting until none of them match
    is_good = 0;
    while ~is_good
        permute_ind = randperm(num_permute);
        
        % Check if any of the indices will be unpermuted
        if isempty(find(permute_ind == 1:num_permute,1))
            is_good = 1;
        end
    end

    % Create the permuted list
    p_shapes = 1:length(shapes);
    p_shapes(to_permute) = to_permute(permute_ind);
    
    % Set the stims
    for j = 1:length(shapes)
        
        % Get the appropriate color
        if p_shapes(j) == j
            
            % Just get one that's different
            p_c = randperm(length(colors));
            if p_c(1) == targets((i-1)*length(shapes) + j,1)
                c = p_c(2); 
            else
                c = p_c(1);
            end
        else
            c = targets((i-1)*length(shapes) + j,1);
        end
        
        % And set
        stim(num_reps*length(shapes) + (i-1)*length(shapes) + j,2:3) = [c p_shapes(j)]; 
    end
end

% Set the fixations
for i = 1:size(stim,1)
    
    % Don't want it to match the color.
    p_f = randperm(length(colors)); 
    if (p_f(1) ~= stim(i,2))
        stim(i,1) = p_f(1);
    else
        stim(i,1) = p_f(2);
    end
end

% Make that one
stims{1} = makeStimList(stim,fixations,colors,shapes,colors,'mod');

% Make the other two lists
for i = 1:2
    
    % Need to permute the wrong ones to
    % make all the shapes wrong.
    is_good = 0;
    while ~is_good
        r_order = randperm(num_reps*length(shapes)) + num_reps*length(shapes);
        if isempty(find(stim(r_order,3) == stim(num_reps*length(shapes)+1:end,5),1))
            stim(num_reps*length(shapes)+1:end,1:3) = stim(r_order,1:3);
            is_good = 1; 
        end
    end
    
    % And make
    if i == 1
        stims{2} = makeStimList(stim,fixations,non_words,shapes,colors,'non');
    else
        stims{3} = makeStimList(stim,fixations,fixations,shapes,colors,'fix');
    end
end



% Helper to print out a stim file
function list = makeStimList(stim,fixations,modifiers,shapes,colors,condition)

% Make each line, in random order
num_i = 0;
list = {};
for i = randperm(size(stim,1))

	% Update the counter
	num_i = num_i + 1;

	% See what the answer is
	if sum(stim(i,2:3) == stim(i,4:5)) == 2
		answer = 'Match';
	else
		answer = 'NoMatch';
	end

	% Make the stimulus line
	list{num_i} = [condition '\t' num2str(num_i) '\t' fixations{stim(i,1)} '.jpg\t'...
		modifiers{stim(i,2)} '.jpg\t' shapes{stim(i,3)} '.jpg\t'...
		colors{stim(i,4)} shapes{stim(i,5)} '_' num2str(stim(i,6)) '.jpg\t' answer];
end
