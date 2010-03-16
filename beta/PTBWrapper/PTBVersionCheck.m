%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBVersionCheck.m
%
% Checks the current version and errrors if we're not
% up to date
%
% Args:
%	- major: The major version number.
%	- minor: The minor version number.
%	- point: The point version number.
%	- mode: How we should relate
%		- at least: Current version must be at least that given.
%		- no more than: Current version must be no more than that given.
%		- less than: Current version must be more than given.
%		- more than: Current version must be less than that given.
%		- exactly: Current version must be exactly that given.
%
% Usage: PTBVersionCheck(1,0,0,'at least')
%
% Author: Doug Bemis
% Date: 3/1/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBVersionCheck(major, minor, point, mode)

% Grab the info
info = PTBWrapperVersion;

% Check and error
for i = 1:3
	if checkValue(i, mode, info, [major, minor, point])
		return;
	end	
end

% Helper...
function value = checkValue(curr, mode, info, version)

% Set what we're checking
version_parts = {'major','minor','point'};
check = version(curr);
actual = info.(version_parts{curr});


% And check
value = -1;
if strcmpi(mode, 'at least')
	if actual > check
		value = 1;
	elseif actual == check
		value = 0;
	end
elseif strcmpi(mode, 'more than')
	if actual > check
		value = 1;
	elseif actual == check && curr < 3
		value = 0;
	end
elseif strcmpi(mode, 'no more than')
	if actual < check
		value = 1;
	elseif actual == check
		value = 0;
	end
elseif strcmpi(mode, 'less than')
	if actual < check
		value = 1;
	elseif actual == check && curr < 3
		value = 0;
	end
elseif strcmpi(mode, 'exactly')
	if actual == check
		value = 0;
	end
else
	error(['Unknown mode: ' mode '.']);
end

% Might have errored
if value < 0	
	
	% Show that we errored
	disp(' ');
	disp(['Version is no good. Need ' mode ' ' num2str(version(1)) '.' ...
		num2str(version(2)) '.' num2str(version(3)) '. Found ' num2str(info.major) '.' ...
		num2str(info.minor) '.' num2str(info.point) '.']);
	disp(' ');
	
	% Give a (hopefully) useful message
	
	if strcmpi(mode, 'at least') || strcmpi(mode, 'more than')
		disp('Try running the command UpdatePTBWrapper.');
	elseif strcmpi(mode, 'exactly') || strcmpi(mode, 'no more than')
		disp(['Try running the command UpdatePTBWrapper([], ' num2str(version(1)) '.' ...
		num2str(version(2)) '.' num2str(version(3)) ').']);
	else
		disp('Try running the command UpdatePTBWrapper([], VERSION).');
		disp(' ');
		d_str = 'Where VERSION is one of the following: ';
		for i = 1:length(info.past_versions)
			d_str = [d_str '; ' info.past_versions{i}];
		end
		disp(d_str);
	end
	disp(' ');
	
	% Error us out
	error('Bad version.');
end

