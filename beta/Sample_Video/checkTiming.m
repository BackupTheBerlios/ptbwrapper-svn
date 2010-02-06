function [run_errors trial_errors isi_1_errors mod_errors isi_2_errors ...
	noun_errors isi_3_errors target_errors condition_counters match_counters ...
	nomatch_counters mod_nm_counters] = checkTiming(first_TRs, warmup_time, cooldown_time, stim_files, opt_files)

% Grab the expected first
expected = getOrdering(opt_files);

% Keep all the errors
run_errors = [];
trial_errors = {};
isi_1_errors = {};
mod_errors = {};
isi_2_errors = {};
noun_errors = {};
isi_3_errors = {};
target_errors = {};

% Keep count
condition_counters = {};
match_counters = {};
nomatch_counters = {};
mod_nm_counters = {};

% Expected times
exp_fix_time = 0.300;
exp_isi_1_time = 0.300;
exp_mod_time = 0.300;
exp_isi_2_time = 0.300;
exp_noun_time = 0.300;
exp_isi_3_time = 0.300;
exp_time_out_time = 1.700;



% Check each file
for i = 1:length(stim_files)
	fid = fopen(stim_files{i});
	
	% Set the time
	curr_time = first_TRs(i) + warmup_time;
	
	% Initialize
	trial_errors{i} = [];
	isi_1_errors{i} = [];
	mod_errors{i} = [];
	isi_2_errors{i} = [];
	noun_errors{i} = [];
	isi_3_errors{i} = [];
	target_errors{i} = [];
	condition_counters{i} = zeros(1,3);
	match_counters{i} = zeros(1,3);
	nomatch_counters{i} = zeros(1,3);
	mod_nm_counters{i} = zeros(1,2);
	if i > 1
		condition_counters{i} = condition_counters{i-1};
	end
	
	% Check each trial
	for j = 1:length(expected{i})
	
		% Read in each actual stimulus
		
		% The fixation
		[stim type fixation time condition item_num answer] = strread(fgetl(fid),'%s%s%s%f%s%f%s');
	
		% Check 
		if strcmp(type{1},'Picture') ~= 1
			error(['Bad fixation in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end
		if isempty(findstr('s',fixation{1}))
			error(['Bad fixation picture in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end
		
		% Record
		trial_errors{i}(j) = time - curr_time;
		c_num = cond2num(condition{1});
		if c_num ~= expected{i}{j}(1)
			error('Wrong condition. Exiting...');
		end
		condition_counters{i}(c_num) = condition_counters{i}(c_num) + 1;
		if condition_counters{i}(c_num) ~= item_num
			condition_counters{i}(c_num)
			error('Missed an item num. Exiting...');
		end
		if strcmp(answer{1},'Match')
			match_counters{i}(c_num) = match_counters{i}(c_num) + 1;
		elseif strcmp(answer{1},'NoMatch')
			nomatch_counters{i}(c_num) = nomatch_counters{i}(c_num) + 1;
		else
			error('Bad answer. Exiting...');
		end
		
		% Update the time
		curr_time = curr_time + exp_fix_time;
		
		% The first isi
		[stim type time c i_t a] = strread(fgetl(fid),'%s%s%f%s%f%s');
		
		% Record
		isi_1_errors{i}(j) = time - curr_time;
		if strcmp(c{1},condition{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if i_t ~= item_num
			error('Non_matching condition. Exiting...');
		end
		if strcmp(a{1},answer{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if strcmp(type{1},'Blank') ~= 1
			error(['Bad blank in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end


		% Update the time
		curr_time = curr_time + exp_isi_1_time;
		
		
		% The modifier
		[stim type modifier time c i_t a] = strread(fgetl(fid),'%s%s%s%f%s%f%s');
		
		% Record
		mod_errors{i}(j) = time - curr_time;
		if strcmp(c{1},condition{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if i_t ~= item_num
			error('Non_matching condition. Exiting...');
		end
		if strcmp(a{1},answer{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if strcmp(modifier{1},fixation{1})
			error('Same fixation as modifier. Exiting...');
		end
		if strcmp(type{1},'Picture') ~= 1
			error(['Bad blank in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end

		% Check
		if strcmp(condition{1},'mod')
			if ~isempty(findstr('1',modifier{1})) || ~isempty(findstr('2',modifier{1})) || ...
					~isempty(findstr('3',modifier{1})) || ~isempty(findstr('4',modifier{1})) || ...
					~isempty(findstr('5',modifier{1})) || ~isempty(findstr('6',modifier{1}))
				error('Bad modifier. Exiting...');
			end
		elseif strcmp(condition{1},'non')
			if isempty(findstr('nw',modifier{1}))
				error('Bad modifier. Exiting...');
			end
		elseif strcmp(condition{1},'fix')
			if isempty(findstr('s',modifier{1}))
				error('Bad modifier. Exiting...');
			end
		end

		% Update the time
		curr_time = curr_time + exp_mod_time;
		
		
		% The second isi
		[stim type time c i_t a] = strread(fgetl(fid),'%s%s%f%s%f%s');
		
		% Record
		isi_2_errors{i}(j) = time - curr_time;
		if strcmp(c{1},condition{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if i_t ~= item_num
			error('Non_matching condition. Exiting...');
		end
		if strcmp(a{1},answer{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if strcmp(type{1},'Blank') ~= 1
			error(['Bad blank in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end


		% Update the time
		curr_time = curr_time + exp_isi_2_time;
		
		
		% The noun
		[stim type noun time c i_t a] = strread(fgetl(fid),'%s%s%s%f%s%f%s');
		
		% Record
		noun_errors{i}(j) = time - curr_time;
		if strcmp(c{1},condition{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if i_t ~= item_num
			error('Non_matching condition. Exiting...');
		end
		if strcmp(a{1},answer{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if strcmp(type{1},'Picture') ~= 1
			error(['Bad blank in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end

		% Update the time
		curr_time = curr_time + exp_noun_time;
		
		
		% The third isi
		[stim type time c i_t a] = strread(fgetl(fid),'%s%s%f%s%f%s');
		
		% Record
		isi_3_errors{i}(j) = time - curr_time;
		if strcmp(c{1},condition{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if i_t ~= item_num
			error('Non_matching condition. Exiting...');
		end
		if strcmp(a{1},answer{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if strcmp(type{1},'Blank') ~= 1
			error(['Bad blank in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end


		% Update the time
		curr_time = curr_time + exp_isi_3_time;
		
		
		% The target
		[stim type target time c i_t a] = strread(fgetl(fid),'%s%s%s%f%s%f%s');
		
		% Record
		target_errors{i}(j) = time - curr_time;
		if strcmp(c{1},condition{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if i_t ~= item_num
			error('Non_matching condition. Exiting...');
		end
		if strcmp(a{1},answer{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if strcmp(type{1},'Picture') ~= 1
			error(['Bad blank in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end

		
		% Check the answer
		mod_match = 0;
		noun_match = 0;
		d_ind = findstr('.',modifier{1});
		if ~isempty(findstr(modifier{1}(1:d_ind-1),target{1}))
			mod_match = 1;
		end
		d_ind = findstr('.',noun{1});
		if ~isempty(findstr(noun{1}(1:d_ind-1),target{1}))
			noun_match = 1;
		end
		if strcmp(condition{1},'mod')
			if strcmp(answer{1},'Match')
				if ~mod_match || ~noun_match
					error('No mod match. Exiting...');
				end
			else
				if mod_match && noun_match
					error('Mod match. Exiting...');
				end	
				if mod_match
					mod_nm_counters{1}(1) = mod_nm_counters{1}(1) + 1;
				else
					mod_nm_counters{1}(2) = mod_nm_counters{1}(2) + 1;
				end
			end
		else
			if strcmp(answer{1},'Match')
				if ~noun_match
					error('No noun match. Exiting...');
				end
			else
				if noun_match
					error('Noun match. Exiting...');
				end				
			end
		end
		
		% The ITI cross
		[stim type cross time c i_t a] = strread(fgetl(fid),'%s%s%s%f%s%f%s');
		
		% Record
		if strcmp(c{1},condition{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if i_t ~= item_num
			error('Non_matching condition. Exiting...');
		end
		if strcmp(a{1},answer{1}) ~= 1
			error('Non_matching condition. Exiting...');
		end
		if strcmp(cross{1},'+') ~= 1
			error('Bad fixation. Exiting...');
		end
		if strcmp(type{1},'Text') ~= 1
			error(['Bad blank in run ' num2str(i) ' at trial ' num2str(j) '. Exiting...']);
		end
		
		% Update the time
		curr_time = curr_time + exp_time_out_time + expected{i}{j}(2);

	end
	

	% The cooldown cross
	[stim type cross time c i_t a] = strread(fgetl(fid),'%s%s%s%f%s%f%s');

	% Record
	if strcmp(c{1},condition{1}) ~= 1
		error('Non_matching condition. Exiting...');
	end
	if i_t ~= item_num
		error('Non_matching condition. Exiting...');
	end
	if strcmp(a{1},answer{1}) ~= 1
		error('Non_matching condition. Exiting...');
	end
	if strcmp(cross{1},'+') ~= 1
		error('Bad fixation. Exiting...');
	end
	if strcmp(type{1},'Text') ~= 1
		error(['Bad cooldown. Exiting...']);
	end

	% Update the time
	curr_time = curr_time + cooldown_time;

	% The end screen
	[stim type w1 w2 w3 w4 w5 time c i_t a] = strread(fgetl(fid),'%s%s%s%s%s%s%s%f%s%f%s');

	% Record
	run_errors(i) = time - curr_time;
	if strcmp(c{1},condition{1}) ~= 1
		error('Non_matching condition. Exiting...');
	end
	if i_t ~= item_num
		error('Non_matching condition. Exiting...');
	end
	if strcmp(a{1},answer{1}) ~= 1
		error('Non_matching condition. Exiting...');
	end
	if strcmp(type{1},'Paragraph') ~= 1
		error(['Bad end. Exiting...']);
	end
	fclose(fid);
end

% Check everything
disp(' ');
disp(['Mean run error: ' num2str(mean(run_errors)) '.']);

t_errors = [];
for i = 1:length(trial_errors)
	t_errors(i) = mean(trial_errors{i});
end
disp(['Mean trial error: ' num2str(mean(t_errors)) '.']);
for i = 1:length(trial_errors)
	disp(['     ' num2str(t_errors(i))]);
end

i1_errors = [];
for i = 1:length(isi_1_errors)
	i1_errors(i) = mean(isi_1_errors{i});
end
disp(['Mean isi_1 error: ' num2str(mean(i1_errors)) '.']);
for i = 1:length(i1_errors)
	disp(['     ' num2str(i1_errors(i))]);
end

m_errors = [];
for i = 1:length(mod_errors)
	m_errors(i) = mean(mod_errors{i});
end
disp(['Mean mod error: ' num2str(mean(m_errors)) '.']);
for i = 1:length(mod_errors)
	disp(['     ' num2str(m_errors(i))]);
end

i2_errors = [];
for i = 1:length(isi_2_errors)
	i2_errors(i) = mean(isi_2_errors{i});
end
disp(['Mean isi_2 error: ' num2str(mean(i2_errors)) '.']);
for i = 1:length(isi_2_errors)
	disp(['     ' num2str(i2_errors(i))]);
end

n_errors = [];
for i = 1:length(noun_errors)
	n_errors(i) = mean(noun_errors{i});
end
disp(['Mean noun error: ' num2str(mean(n_errors)) '.']);
for i = 1:length(noun_errors)
	disp(['     ' num2str(n_errors(i))]);
end

i3_errors = [];
for i = 1:length(isi_3_errors)
	i3_errors(i) = mean(isi_3_errors{i});
end
disp(['Mean isi_3 error: ' num2str(mean(i3_errors)) '.']);
for i = 1:length(isi_3_errors)
	disp(['     ' num2str(i3_errors(i))]);
end

tg_errors = [];
for i = 1:length(target_errors)
	tg_errors(i) = mean(target_errors{i});
end
disp(['Mean target error: ' num2str(mean(tg_errors)) '.']);
for i = 1:length(target_errors)
	disp(['     ' num2str(tg_errors(i))]);
end


% Keep count
disp(' ');
mod_t = 0;
non_t = 0;
fix_t = 0;
mod_m_t = 0;
non_m_t = 0;
fix_m_t = 0;
mod_nm_t = 0;
non_nm_t = 0;
fix_nm_t = 0;
mod_nm_n_t = 0;
mod_nm_m_t = 0;
for i = 1:length(condition_counters)
	mod_t = condition_counters{i}(1);
	non_t = condition_counters{i}(2);
	fix_t = condition_counters{i}(3);
	mod_m_t = mod_m_t + match_counters{i}(1);
	non_m_t = non_m_t + match_counters{i}(2);
	fix_m_t = fix_m_t + match_counters{i}(3);
	mod_nm_t = mod_nm_t + nomatch_counters{i}(1);
	non_nm_t = non_nm_t + nomatch_counters{i}(2);
	fix_nm_t = fix_nm_t + nomatch_counters{i}(3);
	mod_nm_n_t = mod_nm_n_t + mod_nm_counters{i}(1);
	mod_nm_m_t = mod_nm_m_t + mod_nm_counters{i}(2);
end
disp(['All trials: ' num2str(mod_t+non_t+fix_t) '; Mod trials: ' num2str(mod_t) '; Non trials: ' num2str(non_t) '; Fix trials: ' num2str(fix_t) '.']);
disp(['All match trials: ' num2str(mod_m_t+non_m_t+fix_m_t) '; Mod match trials: ' num2str(mod_m_t) '; Non match trials: ' num2str(non_m_t) '; Fix match trials: ' num2str(fix_m_t) '.']);
disp(['All nomatch trials: ' num2str(mod_nm_t+non_nm_t+fix_nm_t) '; Mod nomatch trials: ' num2str(mod_nm_t) '; Non nomatch trials: ' num2str(non_nm_t) '; Fix nomatch trials: ' num2str(fix_nm_t) '.']);
disp(['All mod nomatch trials: ' num2str(mod_nm_n_t+mod_nm_m_t) '; Mod nomatch noun trials: ' num2str(mod_nm_n_t) '; Mod nomatch mod trials: ' num2str(mod_nm_m_t) '.']);



function ordering = getOrdering(run_lists)

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
	
	% And, the end
	fclose(fid);
end

% Convert the condition
function num = cond2num(condition)
if strcmp(condition,'mod')
	num = 1;
elseif strcmp(condition,'non')
	num = 2;
elseif strcmp(condition,'fix')
	num = 3;
else
	error('Bad condition');
end
