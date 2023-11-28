function handles = StimBehavior_Load_Stage(handles)

%
%StimBehavior_Load_Stage.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_LOAD_STAGE loads in the parameters for a single
%   StimBehavior task training/testing stage, displays the stage 
%   information on the GUI, and adjusts the plotting to reflect the updated 
%   parameters.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first created, adapted from
%       ST_Tactile_2AFC_Load_Stage.m.
%

%Show the current stage in the messag box.
str = sprintf('%s - The current stage is "%s".',datestr(now,13),...
    handles.stage(handles.cur_stage).list_description);                     %Create a message string.
Add_Msg(handles.msgbox,str);                                                %Show the message in the messagebox.
handles.dropstage.Items = {handles.stage.list_description};                 %Populate the stage dropdown menu.
handles.dropstage.Value = ...
    handles.stage(handles.cur_stage).list_description;                      %Set the stage dropdown menu value to the current stage.

%Load the timing and task parameters.
for f = {   'min_touch_dur',...
            'min_touch_incr',...
            'max_touch_dur',...
            'choice_win',...
            'debounce',...
            'reward_mode',...
            'force_thresh',...
            'pre_trial_sampling',...
            'post_trial_sampling',...
            'period'}                                                       %Step through the timing parameters.
    handles.(f{1}) = handles.stage(handles.cur_stage).(f{1});               %Copy each parameter to the current stage parameters.
end
handles.reward_mode = lower(handles.reward_mode);                           %Convert the reward mode to lower case.
handles.editdur.Value = sprintf('%1.1f s',handles.min_touch_dur);           %Show the minimum touch duration on the GUI.
handles.editmode.Value = upper(handles.reward_mode);                        %Show the task mode on the GUI.

%Load the stimuli.
disc_stim = {handles.disc.position.label};                                  %Grab the stimuli on the loaded disc.
temp = handles.stage(handles.cur_stage).l_stim;                             %Grab the left stimuli.
if ~any(isnan(temp)) && ~isempty(temp)                                      %If there are left stimuli for this stage...
    handles.l_stim = split(temp,',');                                       %Split up the stimuli based on the comma delimiter.
    handles.l_stim_i = nan(size(handles.l_stim));                           %Create a matrix to hold the stimuli indices.
    for i = 1:numel(handles.l_stim)                                         %Step through each stimuli.
        handles.l_stim{i} = strtrim(handles.l_stim{i});                     %Trim off any leading or trailing spaces from the label.
        p = strcmpi(handles.l_stim{i},disc_stim);                           %Match up the stimulus with the disc position index.
        if any(p)                                                           %If the stimulus matches a position on the wheel.
            handles.l_stim_i(i) = find(p,1,'first');                        %Save the index.
        end
    end
    handles.l_stim_i(isnan(handles.l_stim_i)) = [];                         %Kick out any NaN values.
else                                                                        %Otherwise...
    handles.l_stim = {};                                                    %Set the left stimuli to empty brackets.
    handles.l_stim_i = [];                                                  %Set the left stimuli indices to empty brackets.
end
temp = handles.stage(handles.cur_stage).r_stim;                             %Grab the right stimuli.
if ~any(isnan(temp)) && ~isempty(temp)                                      %If there are right stimuli for this stage...
    handles.r_stim = split(temp,',');                                       %Split up the stimuli based on the comma delimiter.
    handles.r_stim_i = nan(size(handles.r_stim));                           %Create a matrix to hold the stimuli indices.
    for i = 1:numel(handles.r_stim)                                         %Step through each stimuli.
        handles.r_stim{i} = strtrim(handles.r_stim{i});                     %Trim off any leading or trailing spaces from the label.
        p = strcmpi(handles.r_stim{i},disc_stim);                           %Match up the stimulus with the disc position index.
        if any(p)                                                           %If the stimulus matches a position on the wheel.
            handles.r_stim_i(i) = find(p,1,'first');                        %Save the index.
        end
    end
    handles.r_stim_i(isnan(handles.r_stim_i)) = [];                         %Kick out any NaN values.
else                                                                        %Otherwise...
    handles.r_stim = {};                                                    %Set the right stimuli to empty brackets.
    handles.r_stim_i = [];                                                  %Set the right stimuli indices to empty brackets.
end
temp = handles.stage(handles.cur_stage).c_stim;                             %Grab the catch stimuli.
if ~any(isnan(temp)) && ~isempty(temp)                                      %If there are catch stimuli for this stage...
    handles.c_stim = split(temp,',');                                       %Split up the stimuli based on the comma delimiter.
    handles.c_stim_i = nan(size(handles.c_stim));                           %Create a matrix to hold the stimuli indices.
    for i = 1:numel(handles.c_stim)                                         %Step through each stimuli.
        handles.c_stim{i} = strtrim(handles.c_stim{i});                     %Trim off any leading or trailing spaces from the label.
        p = strcmpi(handles.c_stim{i},disc_stim);                           %Match up the stimulus with the disc position index.
        if any(p)                                                           %If the stimulus matches a position on the wheel.
            handles.c_stim_i(i) = find(p,1,'first');                        %Save the index.
        end
    end
    handles.c_stim_i(isnan(handles.c_stim_i)) = [];                         %Kick out any NaN values.
else                                                                        %Otherwise...
    handles.c_stim = {};                                                    %Set the catch stimuli to empty brackets.
    handles.c_stim_i = [];                                                  %Set the catch stimuli indices to empty brackets.
end

%Load the tone parameters.
for f = {   'press_tone_enable',...
            'press_tone_freq',...
            'press_tone_dur',...
            'press_tone_vol',...
            'miss_tone_enable',...
            'miss_tone_freq',...
            'miss_tone_dur',...
            'miss_tone_vol',...
            'hit_tone_enable',...
            'hit_tone_freq',...
            'hit_tone_dur',...
            'hit_tone_vol'}                                                 %Step through the tone parameters.
    handles.(f{1}) = handles.stage(handles.cur_stage).(f{1});               %Copy each parameter to the current stage parameters.
end
handles.press_tone_enable = strcmpi(handles.press_tone_enable,'on');        %Convert the press tone enable value to boolean.
handles.miss_tone_enable = strcmpi(handles.miss_tone_enable,'on');          %Convert the miss tone enable value to boolean.
handles.hit_tone_enable = strcmpi(handles.hit_tone_enable,'on');            %Convert the hit tone enable value to boolean.
if handles.moto.version >= 200                                              %If the controller sketch version is 2.00 or newer...
    StimBehavior_Set_Tone_Parameters(handles);                           %Call the function to update the tone parameters.
end