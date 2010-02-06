%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: createRNEStimLists.m
%
% Creates a RNE stim list
%
% Usage: createRENStimLists
%
% Author: Doug Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function createRNEStimLists

% The different separation values
% NOTE: The last separation value
% serves as the "unconnected" control
separations = [0 4 10 15 30];

% The different set sizes
set_sizes = {[4 6], [10 16], [20 34], [40 60]};

% Number of repetitions
% This will create num_reps*length(set_sizes)*length(separations)*2*2
% The last 2s are: 
%	- smaller / larger number first
%	- first / second display connected
num_reps = 3;

% Number of blocks to use
num_blocks = 5;

% Control of the ITIs
ITI_mean = 0.500;
ITI_std = 0.100;

% Make each trial
trials = {};
for i = 1:num_reps
	for j = 1:length(separations)
		for k = 1:length(set_sizes)

			% These are the inter-trial intervals
			ITIs = randn(4,1)*ITI_std + ITI_mean;
			
			% Make the four different variations
			trials{end+1} = [num2str(set_sizes{k}(1)) '\t' num2str(separations(j)) '\t' ...
				num2str(set_sizes{k}(2)) '\t' num2str(separations(end)) '\t' num2str(ITIs(1))];
			
			trials{end+1} = [num2str(set_sizes{k}(1)) '\t' num2str(separations(end)) '\t' ...
				num2str(set_sizes{k}(2)) '\t' num2str(separations(j)) '\t' num2str(ITIs(2))];
			
			trials{end+1} = [num2str(set_sizes{k}(2)) '\t' num2str(separations(j)) '\t' ...
				num2str(set_sizes{k}(1)) '\t' num2str(separations(end)) '\t' num2str(ITIs(3))];
			
			trials{end+1} = [num2str(set_sizes{k}(2)) '\t' num2str(separations(end)) '\t' ...
				num2str(set_sizes{k}(1)) '\t' num2str(separations(j)) '\t' num2str(ITIs(4))];
		
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
num_practice = 10;
fid = fopen('practice_list.txt','w');
for i = 1:num_practice
	ITI = randn*ITI_std + ITI_mean;
	set = ceil(rand*length(set_sizes));
	sep = ceil(rand*length(separations));
	if rand < .5
		num_1 = set_sizes{set}(1);
		num_2 = set_sizes{set}(2);
	else
		num_1 = set_sizes{set}(2);
		num_2 = set_sizes{set}(1);
	end		
	if rand < .5
		sep_1 = separations(sep);
		sep_2 = separations(end);
	else
		sep_1 = separations(end);
		sep_2 = separations(sep);
	end		
	
	fprintf(fid,[num2str(i) '\t' num2str(num_1) '\t' num2str(sep_1) '\t' ...
		num2str(num_2) '\t' num2str(sep_2) '\t' num2str(ITI) '\n']);
end
fclose(fid);



