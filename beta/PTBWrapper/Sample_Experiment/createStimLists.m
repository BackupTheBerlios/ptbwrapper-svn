%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: createAVStimLists.m
%
% Create the stim lists for the AV experiment.
%
% The created lists will be:
%	- num_blocks lists for visual Comp task.
%	- num_blocks lists for visual List task.
%	- Practice lists for both visual tasks.
%	- num_blocks lists for auditory Comp task.
%	- num_blocks lists for auditory List task.
%	- Practice lists for both auditory tasks.
%
% Controls: 
%	- Same stimuli lists used across modalities.
%	- Critical items are matched across all conditions.
%	- One-word trials created by replacing adjectives.
%	- Same one-word lists across tasks.
%	- List trials also created by replacing adjectives.
%	- Targets are matched within each condition.
%	- Pseudo-randomized with at most max_repititions in a row.
%
% Author: Doug Bemis
% Date: 7/4/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function createStimLists(subject, tasks, mods, conditions, max_repititions, ...
		colors, non_words, first_words, shapes, num_targets, ...
		num_reps, ITI_mean, ITI_std, num_blocks, max_practice_trials)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First create the lists. They all have the same 
% initial and critical stims.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We'll have num_reps * [match / nomatch] * number_shapes
total_stim = num_reps*length(shapes)*2;
total_match = floor(total_stim/2);

% The dimensions are initial, critical, target_ind, target_color, target_num, match
ctr = 0;
comp_stims = zeros(total_stim,6);
one_stims = zeros(total_stim,6);
list_stims = zeros(total_stim,6);

% This controls which list targets match the first or second items
list_m = randperm(total_match);
list_m = list_m(1:floor(end/2));

% Set the initial values
for i = 1:num_reps
	for j = 1:length(shapes)
			
		% No repetitions, for now
		ctr = ctr + 1; 

		% Pick a color
		cs = randperm(length(colors));

		% Don't match earlier repetitions...
		avoid = [];
		for p = 1:i-1
			avoid(end+1) = comp_stims(j + (p-1)*length(shapes),1);
		end
		
		% ...or the the present shape
		avoid(end+1) = j;

		% Go until we get a good one
		for c = cs
			if isempty(find(avoid == c,1))
				break;
			end
		end
		
		% All will have the same initial and critial items and targets.
		tn = ceil(rand*num_targets);
		comp_stims(ctr,:) = [c j j c tn 1];
		one_stims(ctr,:) = [c j j c tn 1];

		% For these, alternate correct between the
		% first and second numbers.
		if isempty(find(list_m == ctr,1))
			list_stims(ctr,:) = [c j c c tn 1];
		else
			list_stims(ctr,:) = [c j j c tn 1];
		end

		% Then, set the "incorrect" ones (though they will
		% be correct for now).
		comp_stims(ctr+ total_match,1:5) = comp_stims(ctr,1:5);
		one_stims(ctr+ total_match,1:5) = one_stims(ctr,1:5);
		list_stims(ctr+ total_match,1:5) = list_stims(ctr,1:5);

	end
end

% Then, permute the wrong answers until they're wrong.
is_good = 0;
while ~is_good

	% NOTE: Only permute the first half here, because we want
	% half the non-matches to match on the shape.
	t = randperm(floor(total_match/2));

	% Check (probably a faster "vectorized" way...)
	used = [];
	
	% Place each possible target...
	for j = 1:length(t)
		
		% ...in the first open wrong place.
		is_good = 0;
		for i = total_match+1:total_match+length(t)
			if isempty(find(used == i,1)) && (comp_stims(i,2) ~= comp_stims(t(j),3))
				is_good = 1;
				used(end+1) = i;
				comp_stims(i,3:5) = comp_stims(t(j),3:5);
				break;
			end
		end
		
		% If didn't place, get out
		if ~is_good
			break;
		end
	end
end

% Now, set the colors...
for i = total_match+1:total_stim

	% Second half does not match on color
	if i > total_match+floor(total_match/2)
		cs = randperm(length(colors));
		if cs(1) == comp_stims(i,1)
			comp_stims(i,4) = cs(2);
		else
			comp_stims(i,4) = cs(1);
		end
		
	% The first half does
	else
		comp_stims(i,4) = comp_stims(i,1);
	end
end

% Set these all not to match
is_good = 0;
while ~is_good
	t = randperm(total_match);

	% Check (probably a faster "vectorized" way...)
	used = [];
	for j = 1:length(t)
		
		is_good = 0;
		for i = total_match+1:total_match+length(t)
			if isempty(find(used == i,1)) && one_stims(i,2) ~= one_stims(t(j),3)
				is_good = 1;
				used(end+1) = i;
				one_stims(i,3:5) = one_stims(t(j),3:5);
				break;
			end
		end
		
		% If didn't place, get out
		if ~is_good
			break;
		end
	end
end

% Set all the lists to be wrong
is_good = 0;
while ~is_good
	t = randperm(total_match);

	% Check (probably a faster "vectorized" way...)
	used = [];
	for j = 1:length(t)
		
		is_good = 0;
		for i = total_match+1:total_match+length(t)
			if isempty(find(used == i,1)) && list_stims(i,1) ~= list_stims(t(j),3) && list_stims(i,2) ~= list_stims(t(j),3)
				is_good = 1;
				used(end+1) = i;
				list_stims(i,3:5) = list_stims(t(j),3:5);
				break;
			end
		end
		
		% If didn't place, get out
		if ~is_good
			break;
		end
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Then, print them out.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Randomize
comp_stims(:,:) = comp_stims(randperm(length(comp_stims)),:);
one_stims(:,:) = one_stims(randperm(length(one_stims)),:);
list_stims(:,:) = list_stims(randperm(length(list_stims)),:);

% Use the helper
printTaskLists(subject, tasks{1}, mods{1}, {conditions{1:2}}, comp_stims, one_stims, max_repititions, ...
	total_stim, num_blocks, ITI_mean, ITI_std, max_practice_trials, colors, shapes, non_words, colors);
printTaskLists(subject, tasks{2}, mods{1}, {conditions{3:4}}, list_stims, one_stims, max_repititions, ...
	total_stim, num_blocks, ITI_mean, ITI_std, max_practice_trials, colors, shapes, non_words, first_words);
printTaskLists(subject, tasks{1}, mods{2}, {conditions{5:6}}, comp_stims, one_stims, max_repititions, ...
	total_stim, num_blocks, ITI_mean, ITI_std, max_practice_trials, colors, shapes, non_words, colors);
printTaskLists(subject, tasks{2}, mods{2}, {conditions{7:8}}, list_stims, one_stims, max_repititions, ...
	total_stim, num_blocks, ITI_mean, ITI_std, max_practice_trials, colors, shapes, non_words, first_words);


% The helper
function printTaskLists(subject, task, modality, conditions, stim_1, stim_2, max_repititions, ...
	total_stim, num_blocks, ITI_mean, ITI_std, max_practice_trials, colors, shapes, non_words, initial_words)

% Either pictures or sounds
if strcmp(modality,'visual')
	suffix = '.jpg';
else
	suffix = '.wav';
end

% Create the order, limiting the number of repetitions.
all_stims = [];
all_conditions = [];
if mod(total_stim, max_repititions) ~= 0
	error('Need max_repititions to be a multiple of the number of stims.');
end
for i = 1:floor(total_stim / max_repititions)
	for j = randperm(max_repititions*2);
		if j > max_repititions
			all_conditions(end+1) = 1;
			all_stims(end+1,:) = stim_1((i-1)*max_repititions + j-max_repititions,:);
		else
			all_conditions(end+1) = 2;
			all_stims(end+1,:) = stim_2((i-1)*max_repititions + j,:);
		end
	end
end


% Make the block lists
curr_block = 0;
for i = 1:length(all_stims)

	% Check for a block
	if mod(i, ceil(length(all_stims) / num_blocks)) == 1
		curr_block = curr_block + 1;
		fid = fopen([subject '_' modality '_' task '_stim_' num2str(curr_block) '.txt'],'w');
	end

	% Print them out
	curr_c = all_conditions(i);

	% Get the target answer and trigger
	if all_stims(i,6) == 1
		answer = 'Match';
		t_trigger = conditions{curr_c}{3}(1);
	else
		answer = 'NoMatch';
		t_trigger = conditions{curr_c}{3}(2);
	end

	% Get the appropriate initial stim
	if curr_c == 1
		initial = initial_words{all_stims(i,1)};
	else
		initial = non_words{all_stims(i,1)};
	end

	% Print out the line
	fprintf(fid,[conditions{curr_c}{1} '\t' num2str(i) '\t' ...
		['Stimuli/' initial suffix '\t'] ['Stimuli/' shapes{all_stims(i,2)} suffix '\t'] ...
		['Stimuli/' colors{all_stims(i,4)} shapes{all_stims(i,3)} '_' num2str(all_stims(i,5)) '.jpg\t'] ...
		num2str(randn*ITI_std + ITI_mean) '\t' num2str(conditions{curr_c}{2}(1)) '\t' ... 
		num2str(conditions{curr_c}{2}(2)) '\t' num2str(conditions{curr_c}{2}(3)) '\t'...
		num2str(t_trigger) '\t' answer '\n']);

	% Check if done with a block
	if mod(i, ceil(length(all_stims) / num_blocks)) == 0
		fclose(fid);
	end
end

% Close the last one, if necessary
if mod(i, ceil(length(all_stims) / num_blocks)) ~= 0
	fclose(fid);
end

% Make two quick practice lists, randomly grabbing from the stims.
for f = 1:2
	p = randperm(length(all_stims));
	fid = fopen([subject '_' modality '_' task '_practice_' num2str(f) '.txt'], 'w');
	for i = p(1:max_practice_trials)

		% Print them out
		curr_c = all_conditions(i);

		% Get the target answer and trigger
		if all_stims(i,6) == 1
			answer = 'Match';
		else
			answer = 'NoMatch';
		end

		% Get the appropriate initial stim
		if curr_c == 1
			initial = initial_words{all_stims(i,1)};
		else
			initial = non_words{all_stims(i,1)};
		end

		% Print out the line
		fprintf(fid,[conditions{curr_c}{1} '\t' num2str(i) '\t' ...
			['Stimuli/' initial suffix '\t'] ['Stimuli/' shapes{all_stims(i,2)} suffix '\t'] ...
			['Stimuli/' colors{all_stims(i,4)} shapes{all_stims(i,3)} '_' num2str(all_stims(i,5)) '.jpg\t'] ...
			num2str(randn*ITI_std + ITI_mean) '\t0\t0\t0\t0\t' answer '\n']);

	end
	fclose(fid);
end
