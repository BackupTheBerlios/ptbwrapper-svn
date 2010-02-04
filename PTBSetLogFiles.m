%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetLogFiles.m
%
% Sets the log files. The second argument will cause all
% responses to be written to a second file. The third
% argument will record all keystrokes during the experiment.
% NOTE: An empty string will write to the command window.
%
% TODO: Possibly allow changing during the experiment.
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetLogFiles(varargin)

if nargin < 1 || nargin > 3
	error('Wrong number of arguments.');
end

% Set
global PTBLogFileName;
PTBLogFileName = varargin{1};

% See if using different files for responses
global PTBDataFileName;
if nargin > 1
	PTBDataFileName = varargin{2};
else
	PTBDataFileName = PTBLogFileName;
end

% See if logging all keystrokes
global PTBKeyFileName;
if nargin > 2
	PTBKeyFileName = varargin{3};
else
	PTBKeyFileName = -1;
end
