function StimTest

% Let's try our experiment
try

     PTBSetupExperiment(127, 'TTest', 1,'ESCAPE', '','');
	% TTest
	fid = fopen('AllStim.txt');
	while 1
		line = fgetl(fid);
		if ~ischar(line)
			break;
		end
		PTBDisplayPicture(line,{-1});
 		PTBDisplayText(line,[400 600],{.2,'a'});
	end
	PTBDisplayText('Done!','center',{'any'});
	PTBCleanupExperiment;

catch
	PTBHandleError;
end
