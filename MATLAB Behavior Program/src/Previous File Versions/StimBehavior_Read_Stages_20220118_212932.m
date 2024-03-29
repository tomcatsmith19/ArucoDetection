function handles = StimBehavior_Read_Stages(handles)

%
%StimBehavior_Read_Stages.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_READ_STAGES reads in the StimBehavior task stage 
%   information from the format (Google Spreadsheet, TSV, or Excel file) 
%   specified by the user.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first created, adapted from
%       ST_Tactile_2AFC_Read_Stages.m
%

global run                                                                  %Create a global run variable.

%List the available column headings with stage structure fieldnames and default values.
params = {  'stage number',                         'number',               'required',         [];... 
            'description',                          'description',          'required',         [];...            
            
            'left stimuli',                         'l_stim',               'optional',         [];...
            'catch stimuli',                        'c_stim',               'optional',         [];...
            'right stimuli',                        'r_stim',               'optional',         [];...
            
            'reward mode',                          'reward_mode',          'required',         'association';...
            
            'force threshold',                      'force_thresh',         'optional',         5;...
            
            'minimum touch duration',               'min_touch_dur',        'optional',         0.025;...
            'minimum touch increment',              'min_touch_incr',       'optional',         [];...
            'maximum touch duration',               'max_touch_dur',        'optional',         [];...
            'debounce',                             'debounce',             'optional',         0;...
            'choice response window',               'choice_win',           'optional',         5.0;...  
            
            'press tone',                           'press_tone_enable',    'optional',         'on';...
            'press tone frequency',                 'press_tone_freq',      'optional',         4000;...
            'press tone duration',                  'press_tone_dur',       'optional',         1000;...
            'press tone volume',                    'press_tone_vol',       'optional',         0.5;...
            'hit tone',                             'hit_tone_enable',      'optional',         'on';...
            'hit tone frequency',                   'hit_tone_freq',        'optional',         8000;...
            'hit tone duration',                    'hit_tone_dur',         'optional',         250;...
            'hit tone volume',                      'hit_tone_vol',         'optional',         1;...
            'miss tone',                            'miss_tone_enable',     'optional',         'on';...
            'miss tone frequency',                  'miss_tone_freq',       'optional',         2000;...
            'miss tone duration',                   'miss_tone_dur',        'optional',         250;...
            'miss tone volume',                     'miss_tone_vol',        'optional',         1;...
            
            'starting position',                    'start_pos',            'required',         [];...
            'maximum position',                     'max_pos',              'optional',         [];...
            'position increment',                   'incr_pos',             'optional',         0.25;...
            'position advance trigger',             'adv_pos',              'optional',         25;...
            
            'pre-trial sampling time',              'pre_trial_sampling',   'optional',         0.5;...
            'post-trial sampling time',             'post_trial_sampling',  'optional',         0.1;...
            'sample period (ms)',                	'period',               'optional',         10;...
        };
                 
        
switch handles.stage_mode                                                   %Switch among the stage selection modes.
    
    case 1                                                                  %If stages are being loaded from a local TSV file.
        stage_file = 'StimBehavior_Stages.tsv';                             %Set the default stage file name.
        file = [handles.mainpath stage_file];                               %Assume the stage file exists in the main program path.
        if ~exist(file,'file')                                              %If the stage file doesn't exist in the main program path...
            file = which(stage_file);                                       %Look through the entire search path for the stage file.    
        end
        if isempty(file)                                                    %If the stage file wasn't found...
            h = warndlg(['The program couldn''t find the stage '...
                'definition file "StimBehavior_Stages.tsv". '...
                'Press "OK" to manually locate the file.'],...
                'NO STAGE FILE');                                           %Show a warning.
            uiwait(h);                                                      %Wait for the warning dialog to close.
            [file, path] = uigetfile('*.tsv','LOCATE STAGE FILE');          %Have the user locate the file with a dialog box.
            if file(1) == 0                                                 %If the user selected "Cancel"...
                run = 0;                                                    %Set the run variable to 0.
                return                                                      %Skip execution of the rest of the function.
            end
            file = [path file];                                             %Add the directory to the located filename.
            temp = questdlg(['The file "' file '" will be copied to "'...
                handles.mainpath '" and will be renamed to '...
                '"StimBehavior_Stages.tsv" for future use.'],...
                'MOVING STAGE FILE','OK','Cancel','OK');                    %Show an OK/Cancel warning that the file will be moved.
            if isempty(temp) || strcmpi(temp,'cancel')                      %If the user closed the warning or pressed "Cancel"...
                run = 0;                                                    %Set the run variable to 0.
                return                                                      %Skip execution of the rest of the function.
            end
            copyfile(file,[handles.mainpath stage_file],'f');               %Copy the stage file to the main data path with the correct filename.
            delete(file);                                                   %Delete the stage file from it's original location.
        end
        stage_file = [handles.mainpath stage_file];                         %Add the main program path to the stage file name.       
        
        data = Vulintus_Read_TSV_File(stage_file);                          %Read in the data from the TSV file.
        for c = 1:size(data,2)                                              %Step through each column of the data.
            data{1,c}(data{1,c} == '"') = [];                               %Kick out any quotation marks in the column heading.
        end
        
    case 2                                                                  %If stages are being loaded from an online google spreadsheet.
        try                                                                 %Try to read in the stage information from the web.
        	data = Read_Google_Spreadsheet(handles.stage_url);              %Read in the stage information from the Google Docs URL.      
            filename = [handles.mainpath ...
                'StimBehavior_Stages.tsv'];                       %Set the filename for the stage backup file.
        	Vulintus_Write_TSV_File(data,filename);                         %Back up the stage information to a local TSV file.
        catch err                                                           %If there's an error...
            warning(['Read_Google_Spreadsheet:' err.identifier],'%s',...
                err.message);                                               %Show a warning.
            stage_file = [handles.mainpath ...
                'StimBehavior_Stages.tsv'];                       %Add the main program path to the stage file name.    
            data = Vulintus_Read_TSV_File(stage_file);                      %Read in the data from the TSV file.
        end
        
end

stage = struct([]);                                                         %Create an empty stage structure.
for c = 1:size(data,2)                                                      %Step through each column of the stage information.    
    fname = [];                                                             %Assume, by default, that the column heading won't match any expected field.
    for p = 1:size(params,1)                                                %Step through every recognized parameter.
        if strncmpi(params{p,1},data{2,c},length(params{p,1}))              %If the column heading matches a recognized parameter.
            fname = params{p,2};                                            %Grab the associated field name.
        end
    end
    if isempty(fname)                                                       %If the column heading didn't match any recognized parameter.
        warndlg(['The stage parameters spreadsheet column heading "' ...
            data{2,c} '" doesn''t match any recognized stage parameter.'...
            ' This parameter will be ignored.'],...
            'STAGE PARAMETER NOT RECOGNIZED');                              %Show a warning that the parameter will be ignored.
    else                                                                    %Otherwise...
        for i = 3:size(data,1)                                              %Step through each listed stage.
            temp = data{i,c};                                               %Grab the entry for this stage.
            temp(temp == 39) = [];                                          %Kick out any apostrophes in the entry.
            if any(temp > 59)                                               %If there's any text characters in the entry...
                stage(i-2).(fname) = strtrim(temp);                         %Save the field value as a string.
            else                                                            %Otherwise, if there's no text characters in the entry.
                stage(i-2).(fname) = str2double(temp);                      %Evaluate the entry and save the field value as a number.
            end
        end        
    end    
end

% for i = 1:numel(stage)                                                      %Step through each stage.
%     stage(i).light_source = [];                                             %Clear each light source fiend.
% end
% 
% for c = 1:size(data,2)                                                      %Step through each column of the stage information.    
%     if strncmpi(data{2,c},'light source',3)                                 %If this column is a light source column.
%         ls_i = str2double(data{2,c}(numel('light source') + 1:end));        %Grab the light source index.       
%         description = data{3,c};                                            %Grab the light source description.
%         model = data{4,c};                                                  %Grab the light source model.
%         for i = 5:size(data,1)                                              %Step through each listed stage.
%             temp = data{i,c};                                               %Grab the entry for this stage.
%             temp(temp == 39) = [];                                          %Kick out any apostrophes in the entry.
%             stage(i-4).light_source(ls_i).value = strtrim(temp);            %Save the field value as a string.
%             stage(i-4).light_source(ls_i).description = description;        %Save the description
%             stage(i-4).light_source(ls_i).model = model;                    %Save the model.
%         end    
%     end
% end
% params(strcmpi(params(:,1),'light source'),:) = [];                         %Kick out the light source row from the parameters.

keepers = ones(length(stage),1);                                            %Create a matrix to mark stages for exclusion.
for p = 1:size(params,1)                                                    %Now step through each parameter.
    if ~isfield(stage,params{p,2})                                          %If the parameter wasn't found in the stage information...
        if strcmpi(params{p,3},'required')                                  %If the parameter was a required parameter...
            errordlg(sprintf(['The required stage parameter "%s" '...
                'wasn''t found in the stage parameters spreadsheet! '...
                'Correct the stage spreadsheet and restart the '...
                'vibration task program.'],...
                upper(params{p,1})),'MISSING STAGE PARAMETER');             %Show an error dialog.
            delete(handles.ardy.serialcon);                                 %Close the serial connection with the Arduino.
            close(handles.mainfig);                                         %Close the GUI.
            clear('run');                                                   %Clear the global run variable from the workspace.
            error(['ERROR IN STIMBEHAVIOR_TASK_READ_STAGES: '...
                'Required stage parameter "' upper(params{p,1}) '" '...
                'wasn''t found in the stage parameters spreadsheet!']);     %Throw an error.
        else                                                                %Otherwise, if the parameter was an optional parameter...
            stage(1).(params{p,2}) = [];                                    %Add the parameter as a new field.
        end
    end
    for i = 1:length(stage)                                                 %Step through each stage.
        if strcmpi(params{p,3},'required') && ...
                any(isnan(stage(i).(params{p,2})))                          %If a required parameter is listed as NaN...
            keepers(i) = 0;                                                 %Mark the stage for exclusion.
        end
    end
end
stage(keepers == 0) = [];                                                   %Kick out any invalid stages.

for p = 1:size(params)                                                      %Now step through each parameter.
    for i = 1:length(stage)                                                 %Step through each stage...
        if (isempty(stage(i).(params{p,2})) || ...
                any(isnan(stage(i).(params{p,2})))) && ...
                ~isempty(params{p,4})                                       %If no parameter value was specified and a default value exists...
            if strcmpi(params{p,4},'special case')                          %If the parameter default value is a special (i.e. conditional) case...
%                 switch lower(params{p,2})                                   %Switch between the special case parameters.
%                     case 'threshtype'                                       %If the parameter is the Threshold Units...
%                         switch lower(stage(i).device)                       %Switch between the device types.
%                             case 'pull'                                     %For the pull device...
%                                 stage(i).threshtype = 'grams (peak)';       %Set the default threshold units to peak force.
%                             case 'squeeze'                                  %For the squeeze device...
%                                 stage(i).threshtype = 'grams (max)';        %Set the default threshold units to maximum force.
%                             case 'knob'                                     %For the knob device...
%                                 stage(i).threshtype = 'degrees (total)';    %Set the default threshold units to total degrees.
%                             case 'lever'                                    %For the lever device...
%                                 stage(i).threshtype = 'degrees (total)';    %Set the default threshold units to total degrees.
%                             case 'touch'                                    %For the touch sensor...
%                                 stage(i).threshtype = ...
%                                     'milliseconds (hold)';                  %Set the default threshold units to milliseconds holding.
%                             case 'both'                                     %For the combined touch/pull device...
%                                 stage(i).threshtype = 'milliseconds/grams'; %Set the default threshold units to milliseconds holding and peak force.
%                             case 'water reach'                              %For the water reach module...
%                                 stage(i).threshtype = ...
%                                     'water reach (shaping)';                %Set the default threshold units to milliseconds holding.
%                         end
%                     case 'threshincr'                                       %If the parameter is the Hit Threshold Increment...
%                         switch lower(stage(i).threshadapt)                  %Switch between the adaptation types.
%                             case {'median','50th percentile'}               %For median adaptation...
%                                 stage(i).threshincr = 20;                   %Set the increment (number of trials to integrate over) to 20.
%                             case 'linear'                                   %For linear adaptation...
%                                 stage(i).threshincr = 0.5;                  %Set the increment (number of units to increase per trial to integrate over) to 0.5.
%                         end                        
%                 end
            else                                                            %Otherwise...
                stage(i).(params{p,2}) = params{p,4};                       %Set the parameter to the default value for this stage.
            end
        end
    end
end

for i = 1:length(stage)                                                     %Step through the stages.
    if ischar(stage(i).number)                                              %If the stage number is a character array...
        stage(i).list_description = ...
            [stage(i).number ': ' stage(i).description];                    %Add the stage number to the stage description.
    else                                                                    %Otherwise...
        stage(i).list_description = ...
            [num2str(stage(i).number) ': ' stage(i).description];           %Add the stage number to the stage description.
    end
end

% 
% if any(vertcat(stage.tones_enabled) == 1)                                   %If any stage has tones enabled...
%     stage(1).tones = [];                                                    %Create a field for tones.
%     for i = 1:length(stage)                                                 %Step through the stages.    
%         if stage(i).tones_enabled == 1                                      %If tones are enabled for this stage...
%             counter = 1;                                                    %Create a counter.
%             for t = 1:num_tones                                             %Step through all tone indices.
%                 fname = sprintf('tone_%1.0f_event',t);                      %Create the expected field name for the tone initiation event.
%                 if ~isempty(stage(i).(fname)) && ...
%                         ~any(isnan(stage(i).(fname)))                       %If the user entered a value for at least one tone initiation event...
%                     stage(i).tones(counter).event = stage(i).(fname);       %Copy the tone event initiation type into the stage structure tone field.
%                     fname = sprintf('tone_%1.0f_freq',t);                   %Create the expected field name for the tone frequency.
%                     stage(i).tones(counter).freq = stage(i).(fname);        %Copy the tone frequency into the stage structure tone field.
%                     fname = sprintf('tone_%1.0f_dur',t);                    %Create the expected field name for the tone duration.
%                     stage(i).tones(counter).dur = stage(i).(fname);         %Copy the tone frequency into the stage structure tone field.
%                     fname = sprintf('tone_%1.0f_thresh',t);                 %Create the expected field name for the tone initiation threshold.
%                     stage(i).tones(counter).thresh = stage(i).(fname);      %Copy the tone initiation threshold into the stage structure tone field.
%                     counter = counter + 1;                                  %Increment the counter.
%                 end
%             end
%         end
%     end
% end
% 
% for t = 1:num_tones                                                         %Step through all tone indices...
%     fname = {sprintf('tone_%1.0f_freq',t),...
%         sprintf('tone_%1.0f_dur',t),...
%         sprintf('tone_%1.0f_event',t)};                                     %Create the list of fields to remove.
%     stage = rmfield(stage,fname);                                           %Remove the redundant tone-related field names from the stage structure.
% end
            
handles.stage = stage;                                                      %Save the stage structure as a field in the handles structure.