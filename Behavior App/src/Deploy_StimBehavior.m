function Deploy_StimBehavior

%
%Deploy_StimBehavior.m - Vulintus, Inc.
%
%   DEPLOY_StimBehavior collates all of the *.m file dependencies for 
%   the StimBehavior task program into a single *.m file and creates 
%   time-stamped back-up copies of each file when a file modification is 
%   detected.
%
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first created, adapted from
%       Deploy_Tactile_Discrimination_Task.m
%

start_script = 'StimBehavior_Startup.m';                                    %Set the expected name of the initialization script.
collated_filename = 'StimBehavior.m';                                       %Set the name for the collated script.

[collated_file, ~] = ...
    Vulintus_Collate_Functions(start_script, collated_filename);            %Call the generalized function-collating script.

[path, file, ext] = fileparts(collated_file);                               %Grab the path from the collated filename.

i = find(path == '\');                                                      %Find all of the forward slashes in the path.
mainpath = path(1:i(end-1));                                                %Find the path to two folder levels up.
copyfile(collated_file, mainpath, 'f');                                     %Copy the collated file to the main path.

file = [file '_' datestr(now, 'yyyymmdd') ext];                             %Create a timestamped filename.
file = fullfile(path, file);                                                %Add the path back to the file.
copyfile(collated_file, file, 'f');                                         %Create a timestamped copy of the collated file.