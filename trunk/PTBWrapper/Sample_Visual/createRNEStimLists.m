%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: createRNEStimLists.m
%
% Creates a RNE stim list
%
% Usage: createRENStimLists
%
% Author: Doug Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function createRNEStimLists(separations, set_sizes, num_reps, num_blocks, ITI_mean, ITI_std, num_practice_trials)

% Make each trial
trials = {};
for i = 1:num_reps
	for j = 1:length(separations)
		for k = 1:length(set_sizes)

			% These are the inter-trial intervals
			ITIs = randn(4,1)*ITI_std + ITI_mean;
			
			% Make the four different variations
			
			% Smaller first, connected first
			trials{end+1} = [num2str(set_sizes{k}(1)) '\t' num2str(separations(j)) '\t' ...
				num2str(set_sizes{k}(2)) '\t' num2str(separations(end)) '\t' num2str(ITIs(1)) ...
				'\t' num2str(k) '\t' num2str(j) '\t1\t1'];
			
			% Smaller first, connected second
			trials{end+1} = [num2str(set_sizes{k}(1)) '\t' num2str(separations(end)) '\t' ...
				num2str(set_sizes{k}(2)) '\t' num2str(separations(j)) '\t' num2str(ITIs(2)) ...
				'\t' num2str(k) '\t' num2str(j) '\t1\t2'];
			
			% Smaller second, connected first
			trials{end+1} = [num2str(set_sizes{k}(2)) '\t' num2str(separations(j)) '\t' ...
				num2str(set_sizes{k}(1)) '\t' num2str(separations(end)) '\t' num2str(ITIs(3)) ...
				'\t' num2str(k) '\t' num2str(j) '\t2\t1'];
			
			% Smaller second, connected second
			trials{end+1} = [num2str(set_sizes{k}(2)) '\t' num2str(separations(end)) '\t' ...
				num2str(set_sizes{k}(1)) '\t' num2str(separations(j)) '\t' num2str(ITIs(4)) ...
				'\t' num2str(k) '\t' num2str(j) '\t2\t2'];
		
		end
	end
end


% Print the stim files
block_num = 0;
trials_per_block = ceil(length(trials) / num_blocks);
p = randperm(length(trials));
for i = 1:length(trials)
	
	% See if we're starting a new block
	if mod(i, trials_per_block) == 1
		if block_num > 0
			fclose(fid);
		end
		block_num = block_num + 1;
		fid = fopen(['stim_list_' num2str(block_num) '.txt'],'w');
	end
	
	% Print the next line
	fprintf(fid,[num2str(i) '\t' trials{p(i)} '\n']);
end

% Close the last one
fclose(fid);

% Create a quick practice list
num_practice = num_practice_trials;
fid = fopen('practice_list.txt','w');
for i = 1:num_practice
	ITI = randn*ITI_std + ITI_mean;
	set = ceil(rand*length(set_sizes));
	sep = ceil(rand*length(separations));
	if rand < .5
		fewer = 1;
		num_1 = set_sizes{set}(1);
		num_2 = set_sizes{set}(2);
	else
		fewer = 2;
		num_1 = set_sizes{set}(2);
		num_2 = set_sizes{set}(1);
	end		
	if rand < .5
		unconnected = 1;
		sep_1 = separations(sep);
		sep_2 = separations(end);
	else
		unconnected = 2;
		sep_1 = separations(end);
		sep_2 = separations(sep);
	end		
	
	fprintf(fid,[num2str(i) '\t' num2str(num_1) '\t' num2str(sep_1) '\t' ...
		num2str(num_2) '\t' num2str(sep_2) '\t' num2str(ITI) '\t' ...
		num2str(set) '\t' num2str(sep) '\t' num2str(fewer) '\t' num2str(unconnected) '\n']);
end
fclose(fid);



