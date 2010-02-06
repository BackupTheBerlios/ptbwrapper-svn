%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: generateStimLists.m
%
% Generate the stimuli lists for the
% visual modification experiment.
%
% This ensures that the same stimuli
% are used for modified and unmodified objects.
%
% Partial trials are unrelated to full trials though,
% (i.e. the randomization is done independently).
%
% The targets are almost matched, except the
% object is changed for the non-word 
%
% Arguments:
%	- run_lists: Output from optseq with the trial ordering
%		for each run.
%
% NOTE: Optseq usage example:
%		TODO: Fix this!
%	- We're expecting full trials to be m1, n1; and partials to be
%		m2,n2,m3,n3.
%
%       optseq: optseq2 --ntp 150 --tr 2 --psdwin 0 20 --ev m1 4 20 
%			--ev n1 4 20 --ev m2 2 10 --ev n2 2 10 --ev m3 2 10 --ev n3 2 10 
%			--nkeep 8 --o VMod --nsearch 10000
%
% Author: Doug Bemis
% Date: 7/5/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function generateStimLists(run_lists)

% The colors to use
colors = {'Red','Blue','Pink',...
    'Black','Green','Brown'};

% The shapes to use
shapes = {'Disc','Plane','Bag','Lock','Cane',...
    'Hand','Key','Shoe','Bone','Square','Bell',...
    'Boat','Bow','Car','Cross','Cup','Flag',...
    'Fork','Heart','Lamp','Leaf','Note',...
    'Star','Tree','House'};

non_words = {'nw1','nw2','nw3','nw4','nw5','nw6'};

% The number of alternative targets we have
num_targets = 3;

% Randomize
rand('twister',sum(100*clock))

% Generate the stimulus list
for i = 1:length(run_lists)
	
	% Parse the ordering
	[order num_full num_part_1 num_part_2] = parseRunFile(run_lists{i});

	% Set the stimulus for the full trials.
	mod_full_stim = {};
	non_full_stim = {};
	for j = 1:num_full
		
		% Pick a random modifier
		mod_ind = ceil(rand*length(colors));
		
		% Take the next object
		obj_ind = mod(j,length(shapes))+1;

		% Pick a target number
		t_num = ceil(rand*num_targets);
		
		% Alternate  match and no-match
		if mod(j,2) == 1
			mod_full_stim{j} = {[colors{mod_ind} '.jpg'] [shapes{obj_ind} '.jpg'] [colors{mod_ind} shapes{obj_ind} '_' num2str(t_num) '.jpg'] 'match'};
			non_full_stim{j} = {[non_words{mod_ind} '.jpg'] [shapes{obj_ind} '.jpg'] [colors{mod_ind} shapes{obj_ind} '_' num2str(t_num) '.jpg'] 'match'};
		else
			
			% Alternate mismatch with color and shape
			if mod(j,4) == 2
				while 1
					nobj_ind = ceil(rand*length(shapes));
					if nobj_ind ~= obj_ind
						break;
					end
				end
				mod_full_stim{j} = {[colors{mod_ind} '.jpg'] [shapes{obj_ind} '.jpg'] [colors{mod_ind} shapes{nobj_ind} '_' num2str(t_num) '.jpg'] 'nomatch'};
				non_full_stim{j} = {[non_words{mod_ind} '.jpg'] [shapes{obj_ind} '.jpg'] [colors{mod_ind} shapes{nobj_ind} '_' num2str(t_num) '.jpg'] 'nomatch'};
			else
				while 1
					nobj_ind = ceil(rand*length(shapes));
					if nobj_ind ~= obj_ind
						break;
					end
				end
				while 1
					nmod_ind = ceil(rand*length(colors));
					if nmod_ind ~= mod_ind
						break;
					end
				end
				mod_full_stim{j} = {[colors{mod_ind} '.jpg'] [shapes{obj_ind} '.jpg'] [colors{nmod_ind} shapes{obj_ind} '_' num2str(t_num) '.jpg'] 'nomatch'};
				non_full_stim{j} = {[non_words{mod_ind} '.jpg'] [shapes{obj_ind} '.jpg'] [colors{nmod_ind} shapes{nobj_ind} '_' num2str(t_num) '.jpg'] 'nomatch'};
			end
			
		end
	end
	
	% Set the first partials
	mod_part_1_stim = {};
	non_part_1_stim = {};
	for j = 1:num_part_1

		% Pick a random modifier
		mod_ind = ceil(rand*length(colors));
		
		% Take the next object
		obj_ind = mod(j,length(shapes))+1;

		mod_part_1_stim{j} = {[colors{mod_ind} '.jpg'] [shapes{obj_ind} '.jpg'] 'none'};
		non_part_1_stim{j} = {[non_words{mod_ind} '.jpg'] [shapes{obj_ind} '.jpg'] 'none'};
	
	end
	
	% Set the second partials
	mod_part_2_stim = {};
	non_part_2_stim = {};
	for j = 1:num_part_2

		% Pick a random modifier
		mod_ind = ceil(rand*length(colors));

		mod_part_2_stim{j} = {[colors{mod_ind} '.jpg'] 'none'};
		non_part_2_stim{j} = {[non_words{mod_ind} '.jpg'] 'none'};
		
	end
	
	% Randomize them all
	p_mod_full = randperm(num_full);
	p_mod_part_1 = randperm(num_part_1);
	p_mod_part_2 = randperm(num_part_2);
	p_non_full = randperm(num_full);
	p_non_part_1 = randperm(num_part_1);
	p_non_part_2 = randperm(num_part_2);
	
	% Choose the ITIs
	% Just uniform: 4,5,6s for now
	ITIs = ceil(rand(1,length(order))*3) + 3;
	
	% For testing, shorter
	ITIs = ITIs / 10;
	
	% Print out the list
	% Counters: 1 - ModFull; 2 - NonFull; 3 - ModP1; 4 - NonP1; 5 - ModP2; 6 - NonP2
	counters = ones(1,6);
	fid = fopen([run_lists{i} '.txt'],'w');
	for j = 1:length(order)
		if strcmp(order{j}, 'm1')
			line = ['mod_full\t' num2str(ITIs(j)) '\t' mod_full_stim{p_mod_full(counters(1))}{4} '\t' mod_full_stim{p_mod_full(counters(1))}{1} '\t' ...
				mod_full_stim{p_mod_full(counters(1))}{2} '\t' mod_full_stim{p_mod_full(counters(1))}{3} '\n'];
			counters(1) = counters(1) + 1;
		elseif strcmp(order{j}, 'm2')
			line = ['mod_part_1\t' num2str(ITIs(j)) '\t' mod_part_1_stim{p_mod_part_1(counters(3))}{3} '\t' mod_part_1_stim{p_mod_part_1(counters(3))}{1} '\t' ...
				mod_part_1_stim{p_mod_part_1(counters(3))}{2} '\n'];
			counters(3) = counters(3) + 1;
		elseif strcmp(order{j}, 'm3')
			line = ['mod_part_2\t' num2str(ITIs(j)) '\t' mod_part_2_stim{p_mod_part_2(counters(5))}{2} '\t' mod_part_2_stim{p_mod_part_2(counters(5))}{1} '\n'];
			counters(5) = counters(5) + 1;
		elseif strcmp(order{j}, 'n1')
			line = ['non_full\t' num2str(ITIs(j)) '\t' non_full_stim{p_non_full(counters(2))}{4} '\t' non_full_stim{p_non_full(counters(2))}{1} ...
				'\t' non_full_stim{p_non_full(counters(2))}{2} '\t' non_full_stim{p_non_full(counters(2))}{3} '\n'];
			counters(2) = counters(2) + 1;
		elseif strcmp(order{j}, 'n2')
			line = ['non_part_1\t' num2str(ITIs(j)) '\t' non_part_1_stim{p_non_part_1(counters(4))}{3} '\t' non_part_1_stim{p_non_part_1(counters(4))}{1} ...
				'\t' non_part_1_stim{p_non_part_1(counters(4))}{2} '\n'];
			counters(4) = counters(4) + 1;
		elseif strcmp(order{j}, 'n3')
			line = ['non_part_2\t' num2str(ITIs(j)) '\t' non_part_2_stim{p_non_part_2(counters(6))}{2} '\t' non_part_2_stim{p_non_part_2(counters(6))}{1} '\n'];
			counters(6) = counters(6) + 1;
		else
			error('Unknown order.');
		end
		fprintf(fid,line);
	end
	fclose(fid);

end


% Helper function
function [order num_full num_part_1 num_part_2] = parseRunFile(run_list)

% Open it up to read
order = {};
num_full = 0;
num_part_1 = 0;
num_part_2 = 0;
% Counters: 1 - ModFull; 2 - NonFull; 3 - ModP1; 4 - NonP1; 5 - ModP2; 6 - NonP2
counters = zeros(1,6);
fid = fopen([run_list '.par']);
while 1
	line = fgetl(fid);
	if ~ischar(line)
		break;
	end
	
	% Grab the condition
	[a b c d c] = strread(line,'%f%f%f%f%s');
	condition = c{1};
	
	% If we're looking for it, record
	shouldUse = 1;
	if strcmp(condition,'m1')
		counters(1) = counters(1) + 1;
	elseif strcmp(condition,'m2')
		counters(3) = counters(3) + 1;
	elseif strcmp(condition,'m3')
		counters(5) = counters(5) + 1;
	elseif strcmp(condition,'n1')
		counters(2) = counters(2) + 1;
	elseif strcmp(condition,'n2')
		counters(4) = counters(4) + 1;
	elseif strcmp(condition,'n3')
		counters(6) = counters(6) + 1;
	else
		shouldUse = 0;
	end
	if shouldUse
		order{length(order)+1} = condition;
	end
end
fclose(fid);

% For now, only expecting matched
if counters(1) ~= counters(2)
	error('Different number of full trials.');
else
	num_full = counters(1);
end
if counters(3) ~= counters(4)
	error('Different number of partial_1 trials.');
else
	num_part_1 = counters(3);
end
if counters(5) ~= counters(6)
	error('Different number of partial_2 trials.');
else
	num_part_2 = counters(5);
end

