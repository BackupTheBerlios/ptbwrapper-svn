function createStimLists

% How many blocks
num_blocks = 4;

% Trials per block
num_trials = 50;

% The sounds to play
wav_file_names = {'Voiced_bilabial_plosive.wav','Voiceless_alveolar_plosive.wav'};

% Make the lists
for i = 1:num_blocks
	fid = fopen(['stim_list_' num2str(i) '.txt'],'w');
	
	% (Pseudo)-Randomly set
	p_rand = randperm(num_trials);
	p_rand = p_rand(1:num_trials/2);
	
	for j = 1:num_trials
		ITI = .6 +.1*randn;
		if isempty(find(p_rand == j,1))
			cond = 1;
		else
			cond = 2;
		end
		fprintf(fid,['c' num2str(cond) '\t' num2str(j) '\t' wav_file_names{cond} '\t' num2str(ITI) '\n']);
	end
	fclose(fid);
end

% Two practice lists too
num_trials = 16;
for i = 1:2
	fid = fopen(['practice_list_' num2str(i) '.txt'],'w');
	
	% (Pseudo)-Randomly set
	p_rand = randperm(num_trials);
	p_rand = p_rand(1:num_trials/2);
	
	for j = 1:num_trials
		ITI = .6 +.1*randn;
		if isempty(find(p_rand == j,1))
			cond = 1;
		else
			cond = 2;
		end
		fprintf(fid,['c' num2str(cond) '\t' num2str(j) '\t' wav_file_names{cond} '\t' num2str(ITI) '\n']);
		end
	end
	fclose(fid);
end
