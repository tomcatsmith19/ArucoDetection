function session = StimBehavior_Initialize_Session(handles)

%
%StimBehavior_Initialize_Session.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_INITIALIZE_SESSION creates and populates the StimBehavior
%   task session data structure.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Task_Initialize_Session(handles).
%

session = [];                                                               %Create a session data structure.

stim_block = vertcat(handles.l_stim_i,handles.r_stim_i,handles.c_stim_i);   %Concatenate all of the active stimuli indices.
stim_block = sort(stim_block);                                              %Sort the active stimuli indices in ascending order.
N = numel(stim_block);                                                      %Grab the number of stimuli.
session.counts = zeros(5, N);                                               %Create a matrix to hold the outcome by disc position.
session.counts(1,:) = stim_block(:,1);                                      %Put a header row at the top of the matrix including the disc position indices.
session.feedings = 0;                                                       %Initialize a feed counter.
% for f = {'aborts','feedings'}                                               %Step through outcome-counting field names...
%     session.(f{1}) = 0;                                                     %Set each field value to zero.
% end
session.touch_times = [];                                                   %Create a field to hold touch times.
% for f = {'outcome',...
%         'hold_time',...
%         'touch_times',...
%         'response_time',...
%         'pad_index',...
%         'target_feeder'}                                                    %Step through trial-tracking field names.
%     session.(f{1}) = [];                                                    %Set each field value to empty brackets.
% end
%session.cal = [handles.slope, handles.baseline];                           %Grab the calibration function for the device.
session.signal_size = handles.pre_trial_sampling + handles.choice_win;      %Calculate the recording duration, in seconds.
session.buffsize = ceil(1000*session.signal_size/handles.period);           %Calculate the recording duration, in samples.
session.buffer = nan(session.buffsize,2);                                   %Create a matrix to buffer the timestamps, force, and nosepoke data.

session.trial_num = 0;                                                      %Create a trial counter.
session.successes = 0;                                                      %Create a field to track successful trials, regardless of hit and miss.

temp = round((1000*handles.debounce)/handles.period);                       %Calculate the number of samples in the debounce.
if temp == 0                                                                %If there's no debounce...
    session.debounce_index = session.buffsize;                              %Set the monitored sample to the last sample in the buffer.
else                                                                        %Otherwise, if debounce is active...
    session.debounce_index = (-(temp-1):1:0) + session.buffsize;            %Calculate the debounce samples.
end
session.pre_sample_N = (1000*handles.pre_trial_sampling)/handles.period;    %Calculate the number of samples in the pre-trial period.
session.pre_sample_indices = ...
    (-(session.pre_sample_N-1):1:0) + session.buffsize;                     %Calculate the pre-trial samples.

%Create the initial stimulus block.
session.stim_block = StimBehavior_Create_Stimulus_Block(handles);           %Create a new stimulus block.
session.stim_index = 1;                                                     %Set the stimulus index to 1.