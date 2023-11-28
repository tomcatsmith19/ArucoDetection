function [session, trial] = StimBehavior_Update_Session(handles, session, trial)

%
%StimBehavior_Update_Session.m - Vulintus, Inc.
%
%   This function adds the results of the most recent trial to the session 
%   data and updates the performance plots for the StimBehavior task.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Update_Session.m.
%


if ~isempty(trial.response_time) && ...
        (trial.response_time <= handles.choice_win)                         %If the subject responded within the choice window...
    
    switch trial.target_feeder                                              %Switch between the two target feeders.
        case 'L'                                                            %If the left feeder was the target.
            if trial.visited_feeder == 'L'                                  %If the left feeder was visited...
                trial.outcome = 'C';                                        %Set the outcome to "C" for a correct rejection.
            else                                                            %Otherwise, if the right feeder was visited...
                trial.outcome = 'F';                                        %Set the outcome to "F" for a false alarm.
            end
        case 'R'                                                            %If the right feeder was the target.
            if trial.visited_feeder == 'L'                                  %If the left feeder was visited...
                trial.outcome = 'M';                                        %Set the outcome to "CM" for a miss.
            else                                                            %Otherwise, if the right feeder was visited...
                trial.outcome = 'H';                                        %Set the outcome to "H" for a false alarm.
            end
    end
                
    switch handles.reward_mode                                              %Switch between the reward modes.
        case 'association'                                                  %If we're doing association mode...
            handles.moto.feed();                                            %Trigger a feeding for any response, but to the correct feeder.
            trial.feed_time(end+1) = now;                                   %Save the feeding time.
            session.feedings = session.feedings + 1;                        %Increment the feed count.     
        case 'operant'                                                      %If we're doing operant mode...
            if any(trial.outcome == 'HC')                                   %If the outcome was either a hit or a correct rejection...
                handles.moto.feed();                                        %Trigger a feeding for any response, but to the correct feeder.
                trial.feed_time(end+1) = now;                               %Save the feeding time.
                session.feedings = session.feedings + 1;                    %Increment the feed count.     
            end
    end
end

%Save the trial information in the session-tracking structure.
if trial.visited_feeder ~= 'N'                                              %If a feeder was visited...
    i = (session.counts(1,:) == trial.pad_index);                           %Find the column for this stimulus index.
    session.counts([2,4],i) = session.counts([2,4],i) + 1;                  %Increment the total trial count for this stimulus.
    session.counts([3,5],i) = session.counts([3,5],i) + ...
        (trial.visited_feeder == 'R');                                      %Increment the total trial count for this stimulus.
end
if ~isempty(trial.touch_time)                                               %If there's a touch duration for this trial.
    session.touch_times(end+1) = trial.touch_time;                          %Save the value in the session tracking structure.
end

%Print a message to the messagebox.
switch trial.outcome                                                        %Switch between the different trial outcome abbreviations.
    case 'A'                                                                %"A"
        outcome = 'ABORT';                                                  %Abort.
    case 'L'                                                                %"L"
        outcome = 'LOITER-NONRELEASE';                                      %Loiter, nonrelease.
    case 'N'                                                                %"N"
        outcome = 'RELEASE-NONRESPONSE';                                    %Release, nonresponse.
    case 'H'                                                                %"H"
        outcome = 'HIT';                                                    %Hit.
    case 'M'                                                                %"M"
        outcome = 'MISS';                                                   %Miss.
    case 'F'                                                                %"F"
        outcome = 'FALSE ALARM';                                            %False alarm.
    case 'C'                                                                %"C"
        outcome = 'CORRECT REJECTION';                                      %Correct rejection.
end        
str = sprintf('%s - Trial #%1.0f, %s, (%s)',datestr(trial.start_time,13),...
    session.trial_num,trial.pad_label,outcome);                             %Start a message for the messagbox.
if ~isempty(trial.touch_time)                                               %If the subject released the carousel...
    str = horzcat(str,sprintf(', TT = %1.2f s',trial.touch_time));          %Add the touch time to the message.
end
if ~isempty(trial.response_time)                                            %If the subject visited a feeder...
    str = horzcat(str,sprintf(', RT = %1.2f s',trial.response_time));       %Add the response time to the message.
end
str = horzcat(str,sprintf(', %1.0f feedings',session.feedings));            %Add the total feed count to the message
Replace_Msg(handles.msgbox,str);                                            %Show the text string on the messagebox.

%Increment to the next stimulus in the stimulus block.
if ~strcmpi(handles.reward_mode,'hold') && ...
        trial.target_feeder ~= 'N' && any(trial.outcome == 'ALN')           %If we're not doing hold training and no feeder was chosen...
    session.stim_block(end+1,:) = session.stim_block(session.stim_index,:); %Move the current trial parameters to the end of the stimulus block.
    session.stim_block(session.stim_index,:) = [];                          %Clear the current line of the stimulus block.
else                                                                        %Otherwise...
    session.stim_index = session.stim_index + 1;                            %Increment the stimulus index.
    if session.stim_index > size(session.stim_block,1)                      %If there's no more parameters in the stimulus block...
        session.stim_block = ...
            StimBehavior_Create_Stimulus_Block(handles);                    %Create a new stimulus block.
        session.stim_index = 1;                                             %Set the stimulus index to 1.
    end
end

data = handles.trialtable.Data;                                             %Grab the data from the trial table.
if isempty(data)                                                            %If this is the first data being written to the table...
    data = cell(1,8);                                                       %Create a cell array with 8 columns.
    i = 1;                                                                  %Set the row index to 1.
else                                                                        %Otherwise...
    i = size(data,1) + 1;                                                   %Find the next row index.
end
data{i,1} = sprintf('%1.0f',session.trial_num);                             %List the trial number.
data{i,2} = datestr(trial.start_time,13);                                   %List the start time.
data{i,3} = trial.pad_label;                                                %List the pad label.
data{i,4} = trial.outcome;                                                  %List the outcome.
data{i,5} = char(trial.target_feeder);                                      %List the target_feeder.
data{i,7} = sprintf('%1.3f',trial.hold_time);                               %List the hold time.
if trial.visited_feeder ~= 'N'                                              %If a feeder was visited...
    data{i,6} = trial.visited_feeder;                                       %Show the visited feeder.
    data{i,9} = sprintf('%1.3f',trial.response_time);                       %Show the response time.
else                                                                        %Otherwise...
    data(i,[6,9]) = {'-'};                                                  %Put a placeholder in those cells.
end
if ~isempty(trial.touch_time)                                               %If there's a valid touch time...
    data{i,8} = sprintf('%1.3f',trial.touch_time);                          %Show the touch time.
else                                                                        %Otherwise...
    data{i,8} = '-';                                                        %Put a placeholder in that cell.
end
handles.trialtable.Data = data;                                             %Push the data back to the trial table.
o = (trial.outcome == handles.table_style.outcomes);                        %Find the style index for this outcome.
addStyle(handles.trialtable,handles.table_style.h(o),'cell',[i,4]);         %Add the appropriate style to the outcome cell.
scroll(handles.trialtable,'bottom');                                        %Scroll to the bottom of the table.