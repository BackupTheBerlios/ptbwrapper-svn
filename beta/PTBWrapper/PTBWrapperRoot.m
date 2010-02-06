%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWrapperRoot.m
%
% Returns the path to the Psychtoolbox folder, even if it's been renamed.
% Also see matlaboot, DiskRoot, [and maybe DesktopFolder].
%
% Author: Doug Bemis (really the psychtoolbox team)
% Date: 2/5/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function path = PTBWrapperRoot

path=which('PTBWrapperRoot');
i=find(filesep==path);
path=path(1:i(end-1));
