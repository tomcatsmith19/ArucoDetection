function StimBehavior_Write_Trial_Data(handles, session, trial)

%
%StimBehavior_Write_Trial_Data.m - Vulintus, Inc.
%
%   This function writes the results of the most recent StimBehavior task 
%   trial to the *.OmniTrak data file.
%   
%   UPDATE LOG:
%   01/18/2021 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Write_Trial_Data.m.
%

%Write the trial outcome to file.
fwrite(session.fid,...
    handles.block_codes.STIMBEHAVIOR_TRIAL_OUTCOME, 'uint16');              %Write the tactile discrimination task outcome block code to the file.
fwrite(session.fid,session.trial_num,'uint16');                             %Write the trial number.
fwrite(session.fid,trial.start_time,'float64');                             %Write the start time of the trial.
fwrite(session.fid,trial.start_millis,'uint32');                            %Write the start time of the trial as recorded on the millisecond clock.
fwrite(session.fid,trial.outcome(1),'uchar');                               %Write the trial outcome as an unsigned character.
fwrite(session.fid,trial.visited_feeder(1),'uchar');                        %Write the visited feeder unsigned character.
fwrite(session.fid,numel(trial.feed_time),'uint8');                         %Write the number of feedings.
if ~isempty(trial.feed_time)                                                %If there were any feedings...
    fwrite(session.fid,trial.feed_time,'float64');                          %Write the serial date number timestamp for every feeding.
end
fwrite(session.fid,handles.max_touch_dur,'float32');                        %Write the maximum touch duration, in seconds.
for f = {'hold_time',...
        'touch_time',...
        'choice_time',...
        'response_time'}                                                    %Step through various fields of the trial structure.
    if isempty(trial.(f{1}))                                                %If the value is empty...
        fwrite(session.fid,NaN,'float32');                                  %Write a NaN as a 32-bit float.
    else                                                                    %Otherwise...
        fwrite(session.fid,trial.(f{1}),'float32');                         %Write each field value as a 32-bit float.
    end
end
fwrite(session.fid,trial.pad_index,'uint8');                                %Write the pad index.
fwrite(session.fid,length(trial.pad_label),'uint8');                        %Write the number of characters in the pad label.
fwrite(session.fid,trial.pad_label,'uchar');                                %Write pad label as unsigned characters.
fwrite(session.fid,1,'uint8');                                              %Number of data streams (besides the timestamp).
fwrite(session.fid,trial.signal_index,'uint32');                            %Write the number of samples in the buffer.
fwrite(session.fid,trial.signal(1:trial.signal_index,1),'uint32');          %Write the microsecond clock timestamps.
fwrite(session.fid,trial.signal(1:trial.signal_index,2),'float32');         %Write the force sensor values.