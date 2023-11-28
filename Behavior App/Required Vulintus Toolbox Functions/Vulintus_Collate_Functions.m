function [varargout] = ...
    Vulintus_Collate_Functions(start_script, collated_filename)

%
%Vulintus_Collate_Functions.m - Vulintus, Inc., 2016
%
%   Vulintus_Collate_Functions collates all of the *.m file dependencies 
%   for the Vulintus program specified by "start_script" into a single *.m
%   file with a filename specified by "collated_filename" and creates
%   time-stamped back-up copies of each subfunction when a file
%   modification is detected. It can then automatically upload the collated
%   script and a zip file containing all function dependencies as separate
%   files to the Vulintus download page.
%
%   UPDATE LOG:
%   08/08/2016 - Drew Sloan - Created the generalized collating function
%       from Deploy_MotoTrak_V1p1.m and removed compiler functions (those
%       are now done in the application compiler app) and added a function
%       to zip all subfunctions.
%   05/05/2018 - Drew Sloan - Added a check to remove duplicates from the
%       dependent function list.
%

varargout = cell(1,2);                                                      %Create a cell array for option output arguments.

h = matlab.desktop.editor.getAll;                                           %Grab all *.m files open in the Matlab Editor.
for i = 1:length(h)                                                         %Step through each open *.m file.
    temp = h(i).Filename;                                                   %Grab the full path filename of the *.m file.
    temp(1:find(temp == '\',1,'last')) = [];                                %Kick out directory preceding the *.m file name.
    if strcmpi(temp,collated_filename)                                      %If any collated MotoTrak program is open for editing...
        h(i).close;                                                         %Close the MotoTrak program in the editor.
    end
end
drawnow;                                                                    %Allow the Editor to finish closing an necessary *.m files in the editor.

start_script = which(start_script);                                         %Grab the entire path of the initialization script.
[program_dir,~,~] = fileparts(start_script);                                %Grab the full path of the initialization script.
program_dir(end+1) = '\';                                                   %Add a forward slash to the path.
backup_dir = [program_dir 'Previous File Versions\'];                       %Set the expected name of the backup directory.
if ~exist(backup_dir,'dir')                                                 %If the backup directory doesn't exist yet...
    mkdir(backup_dir);                                                      %Create it.
end
release_dir = [program_dir 'Collated M Files (Release)\'];                  %Set the expected name of the release directory.
if ~exist(release_dir,'dir')                                                %If the release directory doesn't exist yet...
    mkdir(release_dir);                                                     %Create it.
end

clc;                                                                        %Clear the command line.
fprintf(1,'Checking function dependencies...');                             %Print a line to the command line to show that dependencies are being checked.
depfuns = matlab.codetools.requiredFilesAndProducts(start_script);          %Find all function dependencies for MotoTrak 1.1.
numfuns = 0;                                                                %Find the starting number of function dependencies.
while numfuns ~= length(depfuns)                                            %Loop until no more dependencies are found.    
    numfuns = length(depfuns);                                              %Count how many function dependencies exist at the start of the loop.
    for f = 1:length(depfuns)                                               %Step through each subfunction.        
        if strncmpi(program_dir,depfuns{f},length(program_dir))             %If the subfunction is in the current directory...
            fprintf('.');                                                   %Print another period to the command line.
            temp = matlab.codetools.requiredFilesAndProducts(depfuns{f});   %Find all function dependencies for each subfunction.
            depfuns = union(temp,depfuns);                                  %Add any new function dependencies to the list.
        end
    end
end
depfuns = {start_script, depfuns{:}};                                       %#ok<CCAT> %Add the initialization script to the function list.
keepers = ones(size(depfuns));                                              %Create a matrix to check for duplicates.
for i = 2:numel(depfuns)                                                    %Step through every functions.
    if any(strcmpi(depfuns(1:i-1),depfuns{i}))                              %If this function matches any previous function...
        keepers(i) = 0;                                                     %Mark the function for exclusion.
    end
    [~,~,ext] = fileparts(depfuns{i});                                      %Grab the file extension for the function.
    if ~strcmpi(ext,'.m')                                                   %If this isn't an m-file...
        keepers(i) = 0;                                                     %Mark the file for exclusion.
    end
end
depfuns(keepers == 0) = [];                                                 %Kick out any duplicates from the function list.

clc;                                                                        %Clear the command line.
main_fid = fopen([release_dir collated_filename],'wt');                     %Open a new *.m file to write the new script to.
fprintf(main_fid,'%s\n\n',['function ' collated_filename(1:end-2)]);        %Print the collated function name to the file.
fprintf(main_fid,'%%Compiled: %s\n\n',datestr(now,'mm/dd/yyyy, HH:MM:SS')); %Print the compile time to the file.
fprintf(1,'1: %s\n2:\n',['function ' collated_filename(1:end-2)]);          %Print the collated function name to the command line.
fprintf(1,'3: Compiled: %s\n4:\n',datestr(now,'mm/dd/yyyy, HH:MM:SS'));     %Print the compile time to the command line.
[~, str, ~] = fileparts(depfuns{1});                                        %Grab the startup function name.
fprintf(main_fid,'%s;',str);                                                %Print the startup function name to the file.
fprintf(main_fid,'%s',repmat(' ',1,75 - length(str)));                      %Print spaces to align the comment.
fprintf(main_fid,'%%Call the startup function.\n\n\n');                     %Print a comment for the startup function call.
fprintf(1,'5: %s;',str);                                                    %Print the function name.
fprintf(1,'%s',repmat(' ',1,75 - length(str)));                             %Print spaces to align the comment.
fprintf(1,'%%Call the startup function.\n6:\n7:\n');                        %Print a comment for the startup function call.
ln_num = 8;                                                                 %Create a variable to count the lines across the entire collated m-file.
for f = 1:length(depfuns)                                                   %Step through each included function.
    if strncmpi(program_dir,depfuns{f},length(program_dir))                 %If the subfunction is in the current directory...
        time = dir(depfuns{f});                                             %Grab the file information for the subfunction.
        time = datestr(time.datenum,'_yyyymmdd_HHMMSS');                    %Convert the date modified to a timestamp.
        filename = depfuns{f}(1:end-2);                                     %Grab the m-file name minus the file extension.
        filename(1:find(filename == '\',1,'last')) = [];                    %Kick out the directory name from the file name.
        filename = [backup_dir filename time '.m'];                         %Add a timestamp to the filename.
        if ~exist(filename,'file')                                          %If the backup file doesn't already exist...            
            copyfile(depfuns{f},filename,'f');                              %Copy the subfunction to a timestamped backup.
        end
    end
    ln_num = ln_num + 1;                                                    %Increment the collated m-file line counter.
    fprintf(main_fid,'%%%% ');                                              %Print two parentheses to make a cell divider.
    fprintf(main_fid,'%s\n',repmat('*',1,71));                              %Print asterixes to fill the accentuate the divider.
    fprintf(1,'%1.0f: %%%% ',ln_num);                                       %Print two parentheses to make a cell divider.
    fprintf(1,'%s\n',repmat('*',1,150));                                    %Print 150 asterixes to fill the accentuate the divider.
    sub_fid = fopen(depfuns{f},'rt');                                       %Open the *.m file for reading as text.
    txt = fscanf(sub_fid,'%c');                                             %Read in all the characters of the *.m file.
    fclose(sub_fid);                                                        %Close the *.m file.
    a = 1;                                                                  %Create an index to mark the start of a line.
    b = 1;                                                                  %Create an index to mark the end of a line.    
    c = 0;                                                                  %Create a subfunction line counting variable.
    debug_skip = 0;                                                         %Create a boolean variable to indicate when we're skipping lines of code.
    while b < length(txt)                                                   %Loop until we run out of text.
        if txt(a) == 10                                                     %If the first character is a carriage return...
            c = c + 1;                                                      %Increment the subfunction line counter.
            ln_num = ln_num + 1;                                            %Increment the collated m-file line counter.
            fprintf(main_fid,'\n');                                         %Print a carraige return to the file.
            fprintf(1,'%1.0f:\n',ln_num);                                   %Print the line number to the command line.
            a = b + 1;                                                      %Set the start-of-line index to the next character.
            b = a;                                                          %Set the end-of-line index to the same character.
            ln = txt(a);                                                    %Grab the one-character line of text.
        else                                                                %Otherwise, if the first character isn't a carriage return...
            b = b + 1;                                                      %Advance the end-of-line character index.
            if txt(b) == 10 || b == length(txt)                             %If the end-of-line character is a carriage return...
                c = c + 1;                                                  %Increment the line counter.                
                ln = txt(a:b);                                              %Grab the line of text.
                if ~isempty(strfind(ln,'%end debug code'))                  %If the line indicates the end of a debugging section...
                    if debug_skip == 0                                      %If we're already outside of a debugging section of code...
                        fclose(main_fid);                                   %Close the new *.m file.
                        fprintf(1,'%1.0f: ',c);                             %Print the line number to the command line.
                        fprintf(1,'%s',ln);                                 %Print the line of text to the command line.
                        error(['No preceding ''%start debug code'' '...
                            'marker in "' depfuns{f} '", line ' ...
                            num2str(c)]);                                   %Show an non-matching section error and indicate the line in the *.m file.
                    end
                    debug_skip = 0;                                         %Set the boolean variable to skip the following section.
                elseif ~isempty(strfind(ln,'%start debug code'))            %If the line indicates debugging code to follow...
                    if debug_skip == 1                                      %If we're already within a debugging section of code...
                        fclose(main_fid);                                   %Close the new *.m file.
                        fprintf(1,'%1.0f: ',c);                             %Print the line number to the command line.
                        fprintf(1,'%s',ln);                                 %Print the line of text to the command line.
                        error(['No preceding ''%end debug code'' '...
                            'marker in "' depfuns{f} '", line ' ...
                            num2str(c)]);                                   %Show an non-matching section error and indicate the line in the *.m file.
                    end
                    debug_skip = 1;                                         %Set the boolean variable to skip the following section.
                end
                ln_num = ln_num + 1;                                        %Increment the collated m-file line counter.                
                fprintf(1,'%1.0f: ',ln_num);                                %Print the line number to the command line.
                if debug_skip == 1                                          %If we're in a debugging section...
                    fprintf(1,'%s','%');                                    %Add a comment marker to the start of the command line.
                    fprintf(main_fid,'%s','%');                             %Add a comment marker to the start of the new *.m file line.
                end                    
                fprintf(main_fid,'%s',ln);                                  %Print the line of text to the new *.m file.
                fprintf(1,'%s',ln);                                         %Print the line of text to the command line.
                a = b + 1;                                                  %Set the start-of-line index to the next character.
                b = a;                                                      %Set the end-of-line index to the same character.
            end
        end
    end
    if ln(end) ~= 10                                                        %If the last line isn't a carriage return...
        fprintf(main_fid,'\n');                                             %Print a carraige return to the collated file.
        fprintf(1,'\n');                                                    %Print a carraige return to the command line.
    end
    fprintf(main_fid,'\n\n');                                               %Print two carraige returns to the collated file.
    fprintf(1,'%1.0f:\n%1.0f:\n', ln_num + (1:2));                          %Print two carraige returns to the command line.
    ln_num = ln_num + 2;                                                    %Add two lines to the current line count.
end
fclose(main_fid);                                                           %Close the new *.m file.

time = datestr(now,'_yyyymmdd_HHMMSS');                                     %Convert the current time to a timestamp.
filename = [backup_dir collated_filename(1:end-2) time '.m'];               %Add a timestamp to the filename.
copyfile([release_dir collated_filename],filename,'f');                     %Copy the newly-collated version to a timestamped backup.
                                                    
for f = 1:length(depfuns)                                                   %Step through each included function.
    if f == 1                                                               %If the function is the startup script...
        temp_filename = [tempdir collated_filename];                        %Create a temporary *.m file with the collated filename.
    else                                                                    %Otherwise, for all other functions.
        i = find(depfuns{f} == '\',1,'last');                               %Find the last forward slash in the filename.        
        temp_filename = [tempdir depfuns{f}(i+1:end)];                      %Create a temporary *.m file with the same filename.
    end    
    fid = fopen(temp_filename,'wt');                                        %Open the temporary *.m file to write the new script to.
    if f == 1                                                               %If we're copying the startup script...
        fprintf(fid,'%s\n',['function ' collated_filename(1:end-2)]);       %Print the collated function name to the file.
    end        
    sub_fid = fopen(depfuns{f},'rt');                                       %Open the start script *.m file for reading as text.
    txt = fscanf(sub_fid,'%c');                                             %Read in all the characters of the *.m file.
    fclose(sub_fid);                                                        %Close the *.m file.
    ln_num = 0;                                                             %Reset the line counter.
    a = 1;                                                                  %Create an index to mark the start of a line.
    b = 1;                                                                  %Create an index to mark the end of a line.    
    c = 0;                                                                  %Create a subfunction line counting variable.
    debug_skip = 0;                                                         %Create a boolean variable to indicate when we're skipping lines of code.
    while b < length(txt)                                                   %Loop until we run out of text.
        if txt(a) == 10                                                     %If the first character is a carriage return...
            c = c + 1;                                                      %Increment the subfunction line counter.
            ln_num = ln_num + 1;                                            %Increment the collated m-file line counter.
            fprintf(fid,'\n');                                              %Print a carraige return to the file.
            a = b + 1;                                                      %Set the start-of-line index to the next character.
            b = a;                                                          %Set the end-of-line index to the same character.
            ln = txt(a);                                                    %Grab the one-character line of text.
        else                                                                %Otherwise, if the first character isn't a carriage return...
            b = b + 1;                                                      %Advance the end-of-line character index.
            if txt(b) == 10 || b == length(txt)                             %If the end-of-line character is a carriage return...
                c = c + 1;                                                  %Increment the line counter.                
                ln = txt(a:b);                                              %Grab the line of text.
                if ~isempty(strfind(ln,'%end debug code'))                  %If the line indicates the end of a debugging section...
                    debug_skip = 0;                                         %Set the boolean variable to skip the following section.
                elseif ~isempty(strfind(ln,'%start debug code'))            %If the line indicates debugging code to follow...
                    debug_skip = 1;                                         %Set the boolean variable to skip the following section.
                end
                ln_num = ln_num + 1;                                        %Increment the collated m-file line counter.                
                if ln_num > 1 || f > 1                                      %If this isn't the first line of the startup script...
                    if debug_skip == 1                                      %If we're in a debugging section...
                        fprintf(fid,'%s','%');                              %Add a comment marker to the start of the new *.m file line.
                    end                    
                    fprintf(fid,'%s',ln);                                   %Print the line of text to the new *.m file.
                end
                a = b + 1;                                                  %Set the start-of-line index to the next character.
                b = a;                                                      %Set the end-of-line index to the same character.
            end
        end
    end
    fclose(fid);                                                            %Close the temporary file.
    depfuns{f} = temp_filename;                                             %Copy the temporary filename of each function back into the cell array.
end

[~, zip_filename, ~] = fileparts(collated_filename);                        %Grab the root of the collated filename.
zip_filename = [zip_filename '_MATLAB_' datestr(now,'yyyymmdd') '.zip'];    %Construct the zip filename.
zip_filename = fullfile(release_dir, zip_filename);                         %Create the expected zip filename.
if exist(zip_filename,'file')                                               %If a zip file already exists...
    delete(zip_filename);                                                   %Delete it.
end
zip(zip_filename, depfuns);                                                 %Zip the all functions into one zip file.
for f = 1:length(depfuns)                                                   %Step through each temporary function file.
    delete(depfuns{f});                                                     %Delete each temporary file.
end

varargout{1} = [release_dir collated_filename];                             %Return the collated script name, with path, as the first optional output argument.
varargout{2} = zip_filename;                                                %Return the full function zip file, with path, as the second optional output argument.