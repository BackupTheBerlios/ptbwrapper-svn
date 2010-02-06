function [num_mod num_non num_fix num_mod_m num_mod_nm ...
	num_non_m num_non_nm num_fix_m num_fix_nm ...
	num_mod_nm_1 num_mod_nm_2] = checkStimLists(lists)

num_mod = 0;
num_non = 0;
num_fix = 0;
num_mod_m = 0;
num_mod_nm = 0;
num_non_m = 0;
num_non_nm = 0;
num_fix_m = 0;
num_fix_nm = 0;
num_mod_nm_1 = 0;
num_mod_nm_2 = 0;


for i = 1:length(lists)
	fid = fopen(lists{i});
	while 1
		line = fgetl(fid);
		if ~ischar(line)
			break;
		end
		
		[cond num fix mod noun target answer time] = strread(line,'%s%f%s%s%s%s%s%f');
		if strcmp(cond{1},'mod')
			num_mod = num_mod + 1;
			
			% Check fixation
			if isempty(findstr('s',fix{1}))
				error('Bad fixation');
			end
			
			% Check mod
			if ~isempty(findstr('s',mod{1})) || ~isempty(findstr('nw',mod{1}))
				error('Bad modification');
			end
			
			if strcmp('Match',answer{1})
				num_mod_m = num_mod_m + 1;
				if isempty(findstr(mod{1}(1:end-4),target{1})) || isempty(findstr(noun{1}(1:end-4),target{1}))
					error('Bad Target');
				end
			else
				num_mod_nm = num_mod_nm + 1;
				if isempty(findstr(mod{1}(1:end-4),target{1})) 
					if isempty(findstr(noun{1}(1:end-4),target{1}))
						error('Bad Target');
					end
					num_mod_nm_1 = num_mod_nm_1 + 1;
				else
					if ~isempty(findstr(noun{1}(1:end-4),target{1}))
						error('Bad Target');
					end
					num_mod_nm_2 = num_mod_nm_2 + 1;
				end				
			end
		elseif strcmp(cond{1},'non')
			num_non = num_non + 1;
			
			% Check fixation
			if isempty(findstr('s',fix{1}))
				error('Bad fixation');
			end
			
			% Check mod
			if isempty(findstr('nw',mod{1}))
				error('Bad modification');
			end
			
			% Check target
			if strcmp('Match',answer{1})
				num_non_m = num_non_m + 1;
				if isempty(findstr(noun{1}(1:end-4),target{1}))
					error('Bad Target');
				end
			else
				num_non_nm = num_non_nm + 1;
				if ~isempty(findstr(noun{1}(1:end-4),target{1}))
					error('Bad Target');
				end
			end
		else
			num_fix = num_fix + 1;
			
			% Check fixation
			if isempty(findstr('s',fix{1}))
				error('Bad fixation');
			end
			
			% Check mod
			if isempty(findstr('s',mod{1})) || strcmp(fix{1},mod{1})
				error('Bad modification');
			end
			
			% Check target
			if strcmp('Match',answer{1})
				num_fix_m = num_fix_m + 1;
				if isempty(findstr(noun{1}(1:end-4),target{1}))
					error('Bad Target');
				end
			else
				num_fix_nm = num_fix_nm + 1;
				if ~isempty(findstr(noun{1}(1:end-4),target{1}))
					error('Bad Target');
				end
			end
		end
	end
	fclose(fid);
end

% check
if num_mod ~= 150 || num_non ~= 150 || num_fix ~= 150 ...
		|| num_mod_m ~= 75 || num_fix_m ~= 75 || num_fix_m ~= 75 ...
		|| num_fix_nm ~= 75 || num_fix_nm ~= 75 || num_fix_nm ~= 75
	error('Wrong numbers');
end