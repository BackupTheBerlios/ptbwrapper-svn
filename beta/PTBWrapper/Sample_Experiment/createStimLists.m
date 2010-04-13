%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: createStimLists.m
%
% Creates the stim lists for the sample experiment.
% 
% Author: Doug Bemis
% Date: 4/12/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function createStimLists(conditions, triggers, pictures, picture_folder, num_practice_trials,...
	num_blocks, num_cond_reps, decisions_percent, gabor_tilt, ITI_mean, ITI_std)

% The picture suffixes
c_suffixes = {{'front','mask'},{'mask','front'}};

% Create the possible pairs
picture_pairs = [];
for i = 1:length(pictures)
	for j = 1:length(pictures)
        if i ~= j
            picture_pairs(end+1, 1:2) = [i j];
        end
	end
	
	% Randomize for masks
	r = randperm(length(pictures)-1);
	num_left = floor(length(r) / 2);
	if mod(length(r),2) ~= 0 && mod(i,2) ~= 0
		num_left = num_left+1;
	end
	picture_pairs(r(1:num_left) + (i-1)*(length(pictures)-1),3) = 1;
	picture_pairs(r(num_left+1:end) + (i-1)*(length(pictures)-1),3) = 0;
end

% And randomize
num_pairs = size(picture_pairs,1);
picture_pairs = picture_pairs(randperm(num_pairs),:);

% Hold the condition pairs
% Want them all to use the same stimuli
c_pairs = zeros(length(conditions),num_cond_reps);
for i = 1:floor(num_cond_reps / num_pairs)
	for j = 1:length(conditions)
		c_pairs(j, 1 + (i-1)*num_pairs:i*num_pairs) = 1:num_pairs;
	end
end

% Add the last
if isempty(i)
	i = 0;
end
for j = 1:length(conditions)
	c_pairs(j, 1 + i*num_pairs:end) = 1:mod(num_cond_reps, num_pairs);
	c_pairs(j,:) = c_pairs(j,randperm(size(c_pairs,2)));
end

% Check how many trials per block
num_trials_per_block = floor(num_cond_reps / num_blocks);

% Add each set of conditions
block_num = 0;
d_ctr = 0;
m_ctr = 0;
for i = 1:num_cond_reps
	
	% See if we need a new block
	if mod(i, num_trials_per_block) == 1
		block_num = block_num + 1;
		fid = fopen(['stim_list_' num2str(block_num) '.txt'],'w');
	end
	
	% Print out the next set
	for j = randperm(length(conditions));
		
		% Get the picture pairs
		curr_pair = picture_pairs(c_pairs(j,i),1:2);
		
		% Print out the stim line
		fprintf(fid, [conditions{j} '\t' num2str(i) '\t' ]);
		
		% Replace masks for 'one' condition
		suffixes = [1 2];
		if j == 1
			is_mask =  picture_pairs(c_pairs(j,i),3);
			if is_mask
				suffixes = [2 1];
			end
		end
		
		% Get the pictures
		picture_prefix = '';
		if ~isempty(picture_folder)
			picture_prefix = [picture_folder '/'];
		end
		fprintf(fid, [picture_prefix pictures{curr_pair(1)} '_' c_suffixes{j}{suffixes(1)} '.png\t' ...
			picture_prefix pictures{curr_pair(2)} '_' c_suffixes{j}{suffixes(2)} '.png\t' ]);
		
		% The ITI
		ITI = randn*ITI_std + ITI_mean;
		fprintf(fid, [num2str(ITI) '\t' ]);
        
        % Give the trigger
        fprintf(fid, [num2str(triggers(j)) '\t']);

		% See if we want a decision
		if rand < decisions_percent
			
			% Might need to reset
			if mod(d_ctr,4) == 0
				d_ctr = 1;
				decisions = randperm(4);
			end
			
			% Set the tilts
			if decisions(d_ctr) == 1
				tilts = [gabor_tilt gabor_tilt];
			elseif decisions(d_ctr) == 2
				tilts = [gabor_tilt -1*gabor_tilt];
			elseif decisions(d_ctr) == 3
				tilts = [-1*gabor_tilt gabor_tilt];
			else
				tilts = [-1*gabor_tilt -1*gabor_tilt];
			end
			
			% Print out
			fprintf(fid,['decision\t' num2str(tilts(1)) '\t' num2str(tilts(2))]);
			
			% And advance
			d_ctr = d_ctr + 1;
		else
			fprintf(fid,'no_decision\t-1\t-1');			
		end
		
		% End the line
		fprintf(fid,'\n');
	end
	
	% Might be done
	if mod(i, num_trials_per_block) == 0
		fclose(fid);
	end
	
end
if mod(i, num_trials_per_block) ~= 0
	fclose(fid);
end

% Create a random practice list
fid = fopen('practice_list.txt','w');
for i = 1:num_practice_trials
	
	% Pick a condition
	c = ceil(rand*length(conditions));
			
	% Get a picture pair
	curr_pair = picture_pairs(ceil(rand*num_pairs),:);

	% Print out the stim line
	fprintf(fid, [conditions{c} '\t' num2str(i) '\t' ]);
		
	% Switch the picture order for half the masks
	suffixes = [1 2];
	if c == 1
		if rand < 0.5
			suffixes = [2 1];
		end
	end
		
	% Get the pictures
	picture_prefix = '';
	if ~isempty(picture_folder)
		picture_prefix = [picture_folder '/'];
	end
	fprintf(fid, [picture_prefix pictures{curr_pair(1)} '_' c_suffixes{c}{suffixes(1)} '.png\t' ...
		picture_prefix pictures{curr_pair(2)} '_' c_suffixes{c}{suffixes(2)} '.png\t' ]);
		
	% The ITI
	ITI = randn*ITI_std + ITI_mean;
	fprintf(fid, [num2str(ITI) '\t' ]);
            
    % No Trigger for practice
    fprintf(fid, '0\t');

	% See if we want a decision
	if rand < decisions_percent
		d_type = ceil(rand*4);
		
		% Set the tilts
		if d_type == 1
			tilts = [gabor_tilt gabor_tilt];
		elseif d_type == 2
			tilts = [gabor_tilt -1*gabor_tilt];
		elseif d_type == 3
			tilts = [-1*gabor_tilt gabor_tilt];
		else
			tilts = [-1*gabor_tilt -1*gabor_tilt];
		end

		% Print out
		fprintf(fid,['decision\t' num2str(tilts(1)) '\t' num2str(tilts(2))]);
	else
		fprintf(fid,'no_decision\t-1\t-1');			
	end
		
	% End the line
	fprintf(fid,'\n');
end
fclose(fid);

