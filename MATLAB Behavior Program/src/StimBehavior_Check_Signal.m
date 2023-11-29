function [trial, session] = StimBehavior_Check_Signal(handles, session, trial)

%
%StimBehavior_Check_Signal.m - Vulintus, Inc.
%
%   StimBehavior_CHECK_SIGNAL checks the OmniTrak controller for new 
%   streaming data from the nosepoke and pellet reciever and adds any new 
%   data it finds to the trial initiation monitored signal.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Check_Signal.m
%

new_data = handles.moto.read_stream();                                      %Read in any new stream output.
N = size(new_data,1);                                                       %Find the number of new samples.

if ~N                                                                       %If there's no new data...
    return                                                                  %Skip the rest of the function.
end

new_data(:,2) = handles.slope*(new_data(:,2) - handles.baseline);           %Apply the calibration constants to the primary data signal.
session.buffer(1:end-N,:) = session.buffer(N+1:end,:);                      %Shift the existing force buffer samples to make room for the new samples.
session.buffer(end-N+1:end,:) = new_data(:,1:2);                            %Add the new samples to the buffer.

trial.status_flag(2) = any(session.buffer(session.debounce_index,2) > ...
    handles.force_thresh);                                                  %Check for any force samples exceeding the threshold.
trial.status_flag(3:4) = any(new_data(:,3:4) > handles.ir_thresh,1);        %Check for any nosepoke events.
    
StimBehavior_Update_Sensor_Diagrams(handles,trial.status_flag(2:4));        %Update the sensor diagrams.

% if isempty(trial.start_time)                                                %If there's no active trial..        
%     StimBehavior_Update_Force_Plot(handles,session.buffer(:,2));            %Update the force plot with the session buffer.    
%     drawnow;                                                                %Update the figure and execute any waiting callbacks.
%     return                                                                  %Skip the rest of the function.
% end

trial.signal(trial.signal_index + (1:N),:) = new_data(:,1:2);               %Copy the new data to the trial force signal.
trial.signal_index = trial.signal_index + N;                                %Increment the trial signal index.
StimBehavior_Update_Force_Plot(handles,trial.signal(:,2));                  %Update the force plot with the current trial signal.

if isempty(trial.touch_time) && (~trial.status_flag(2))                     %If the carousel was released for the first time...
    i = find(trial.signal(:,2) > handles.force_thresh,1,'last');            %Find the last supra-threshold sample...
    trial.touch_time = (trial.signal(i,1) - trial.start_millis)/1000000;    %Grab the time the rat held.
    if trial.touch_time > handles.max_touch_dur                             %If the subject never let go of the carousel...        
        trial.outcome = 'L';                                                %Set the outcome to "L" for loitering.
        trial.status_flag(1) = 0;                                           %Set the status flag to zero.
    elseif strcmpi(handles.reward_mode,'hold')                              %If this is a hold reward paradigm...        
        if trial.touch_time >= trial.hold_time                              %If the subject held through the hold time...
            handles.moto.feed();                                            %Trigger a feeding.
            trial.feed_time(end+1) = now;                                   %Save the feeding time.
            session.feedings = session.feedings + 1;                        %Increment the feed count.
        else                                                                %Otherwise...
            trial.status_flag(1) = 0;                                       %Set the status flag to zero.
            trial.outcome = 'A';                                            %Set the outcome to "A" for abort.
        end        
    end
    handles.moto.stop_tone();                                               %Stop any press tone.
elseif ~strcmpi(handles.reward_mode,'hold') && ...
        ~isempty(trial.touch_time) && (trial.status_flag(2))                %If the carousel was re-engaged and this isn't a hold training session...
    trial.touch_time = [];                                                  %Reset the touch time tracker.
end

if any(trial.status_flag(3:4))                                              %If any of the pellet receivers are blocked...
    feeder_chars = 'LR';                                                    %Set the characters for the feeders.
    [i,j] = find(new_data(:,3:4) > handles.ir_thresh);                      %Find the first blocked sample.
    trial.response_time = (new_data(i(1),1) - trial.start_millis)/1000000;  %Grab the response time.    
    trial.visited_feeder = feeder_chars(j(1));                              %Save the visited feeder label.
    trial.status_flag(1) = 0;                                               %Set the status flag to zero.
end
drawnow;                                                                    %Update the figure and execute any waiting callbacks.