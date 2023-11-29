function trial = StimBehavior_Reset_Trial(handles, session, trial)

%
%StimBehavior_Reset_Trial.m - Vulintus, Inc.
%
%   This function resets all trial variables at the start of a session or 
%   following a completed trial to prepare monitoring for the next trial
%   initiation in the StimBehavior task.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Reset_Trial
%

%Reset the flags for trial control.
trial.status_flag = [1, 0, 0, 0];                                           %Create a flag matrix for tracking progress through the trial.

%Create/reset fields to hold trial results.
trial.start_time = [];                                                      %Create an empty field for the trial start time.
trial.touch_time = [];                                                      %Create an empty field for a touch time.
trial.feed_time = [];                                                       %Create an empty field to hold feeding times.
trial.response_time = [];                                                   %Create an empty field for a pellet receiver choice time.
trial.outcome = 'N';                                                        %Assume the trial outcome is a nonresponse, by default.
trial.visited_feeder = 'N';                                                 %Assume no feeder is visited by default.             

%Set the stimulus parameters.
trial.hold_time = handles.min_touch_dur;                                    %Set the initial hold time.
if ~isempty(handles.min_touch_incr) && handles.min_touch_incr > 0           %If there's a touch time increment.
    trial.hold_time = handles.min_touch_incr*session.successes + ...
        trial.hold_time;                                                    %Add the current increment to the touch time.
    trial.hold_time = min(trial.hold_time,handles.max_touch_incr);          %Set the touch time to the minimum of the calculated value or the maximum allowable touch time.
end
trial.choice_time = handles.choice_win;                                     %Grab the choice window.
trial.pad_index = session.stim_block(session.stim_index,1);                 %Grab the pad index.
trial.pad_label = handles.disc.position(trial.pad_index).label;             %Grab the pad label.
trial.target_feeder = session.stim_block(session.stim_index,2);             %Grab the target feeder.

%Rotate the current pad into position.
% handles.ctrl.rotate;

%Create a trial force signal buffer.
trial.signal = nan(session.buffsize, 2);                                    %Create a matrix to hold the trial signal.
trial.signal_index = 0;                                                     %Create a variable to track the current signal index.

%Update the psychometric plot and the messagebox to show the queued stimulus.
str = sprintf('%s - Next stimulus queued: %s',datestr(now,13),...
    trial.pad_label);                                                       %Create a string to show the next stimulus.
% StimBehavior_Update_Psychometric_Plot(handles.psych_plots,...
%     session.counts,session.touch_times,trial.pad_index);                    %Update the psychometric plot.
Add_Msg(handles.msgbox,str);                                                %Show the string in the messagebox.