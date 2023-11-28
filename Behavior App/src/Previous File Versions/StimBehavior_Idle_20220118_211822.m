function StimBehavior_Idle(fig)

%
%StimBehavior_Idle.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_IDLE runs in the background to display the streaming 
%   input signals from the StimBehavior task while a session is not 
%   running.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Idle.m.
%

global run                                                                  %Create the global run variable.

handles = guidata(fig);                                                     %Grab the handles structure from the main GUI.

%Update all of the uicontrols.
handles = StimBehavior_Update_Controls_During_Idle(handles);                %Call the function to update all of the uicontrols.

%Initialize the plots.
if ~isfield(handles,'diagram') || ~ishandle(handles.diagram.carousel)       %If the carousel and pellet receiver diagrams aren't yet made...
    handles = StimBehavior_Create_Sensor_Diagrams(handles);                 %Call the function to create them.
end
if ~isfield(handles,'force_plot') || ~ishandle(handles.force_plot)          %If the force plot isn't yet initialized...
    handles = StimBehavior_Create_Force_Plot(handles);                      %Call the function to create them.
end
handles.psych_plots = ...
    StimBehavior_Initialize_Psychometric_Plot(handles);                     %Create the psychometric plots.
[counts, times] = StimBehavior_Load_Previous_Performance(handles);          %Call the function to load the current subject's previous performance.
StimBehavior_Update_Psychometric_Plot(handles.psych_plots,counts,times);    %Update the psychometric plots with the current and historical performance.

guidata(handles.mainfig,handles);                                           %Re-pin the handles structure to the main figure.    

%Start the idle loop.
force = [];                                                                 %Create an empty matrix to hold the force signal.
handles.moto.clear();                                                       %Clear any residual values from the serial line.
run = 1.2;                                                                  %Set the run variable to 1.2 to create the plot variables.

while fix(run) == 1                                                         %Loop until the user starts a session, runs the calibration, or closes the program.
    
    switch run                                                              %Switch between recognized run variable values.
        
        case 1.1                                                            %If the user has selected a new stage...
            handles = guidata(fig);                                         %Grab the handles structure from the main GUI.
            temp = handles.dropstage.Value;                                 %Grab the value of the stage select dropdown menu.
            i = find(strcmpi(temp,handles.dropstage.Items));                %Find the index of the selected stage.
            if i ~= handles.cur_stage                                       %If the selected stage is different from the current stage.
                handles.cur_stage = i;                                      %Set the current stage to the selected stage.
                handles = StimBehavior_Load_Stage(handles);                 %Load the new stage parameters. 
            end
            handles.psych_plots = ...
                StimBehavior_Initialize_Psychometric_Plot(handles);         %Recreate the psychometric plots.
            [counts, times] = ...
                StimBehavior_Load_Previous_Performance(handles);            %Call the function to load the current subject's previous performance.
            StimBehavior_Update_Psychometric_Plot(...
                handles.psych_plots,counts,times);                          %Update the psychometric plots with the current and historical performance.
            guidata(handles.mainfig,handles);                               %Re-pin the handles structure to the main figure.
            run = 1.2;                                                      %Set the run variable to 1.3 to create the plot variables.
            
        case 1.2                                                            %If new plot variables must be created...
            handles.moto.stream_enable(0);                                  %Disable streaming on the Arduino.
            StimBehavior_Set_Stream_Params(handles);                        %Update the streaming properties on the Arduino.   
            handles.moto.clear();                                           %Clear any residual values from the serial line.        
            handles.buffsize = 3000/handles.period;                         %Calculate the number of samples in a 3-second buffer.
            if handles.buffsize ~= numel(force)
                force = nan(handles.buffsize,1);                            %Create a matrix to hold the monitored signal.
            end        
            handles.moto.stream_enable(1);                                  %Re-enable periodic streaming on the Arduino.
            run = 1;                                                        %Set the run variable back to 1.
            
        case 1.3                                                            %If the user pressed the manual feed button...     
            handles.moto.feed();                                            %Trigger feeding on the Arduino.
            Add_Msg(handles.msgbox,[datestr(now,13) ' - Manual Feeding.']); %Show the user that the session has ended.
            run = 1;                                                        %Set the run variable back to 1.
            
        case 1.4                                                            %If the user wants to reset the baseline...
            handles = guidata(fig);                                         %Grab the current handles structure from the main GUI.
            N = fix(1000/handles.period);                                   %Find the number of samples in the last second of the existing signal.
            temp = force(end-N+1:end);                                      %Convert the buffered data back to the uncalibrated raw values.
            fprintf(1,'old_baseline = %1.2f\n',handles.baseline);           %Convert the buffered data back to the uncalibrated raw values.
            handles.baseline = ...
                (mean(temp,'omitnan')/handles.slope) + handles.baseline;    %Set the baseline to the average of the last 100 signal samples.
            fprintf(1,'new_baseline = %1.2f\n',handles.baseline);           %Convert the buffered data back to the uncalibrated raw values.
            guidata(fig,handles);                                           %Pin the updated handles structure back to the GUI.
            handles.moto.set_baseline_float(10,handles.baseline);           %Save the baseline as a float in the EEPROM address for the current module.
            run = 1;                                                        %Set the run variable back to 1.
            
        case 1.5                                                            %If the user selected the "Launch Webcam" menu item...
            Vulintus_Behavior_Launch_Webcam_Preview;                        %Call the function to launch a webcam preview.
            run = 1;                                                        %Set the run variable back to 1.
            
        case 1.6                                                            %If the subject has been changed.
            handles = guidata(fig);                                         %Grab the current handles structure from the main GUI.
            str = sprintf('%s - The current subject is "%s".',...
                datestr(now,13),handles.subject);                           %Create a message.
            Add_Msg(handles.msgbox,str);                                    %Show the message in the messagebox.
            [counts, times] = ...
                StimBehavior_Load_Previous_Performance(handles);         %Call the function to load the current subject's previous performance.
                StimBehavior_Update_Psychometric_Plot(...
                    handles.psych_plots,counts,times);                      %Update the psychometric plots with the current and historical performance.
            handles.trialtable.Data = {};                                   %Clear any existing data from the trial table.
            handles.trialtable.Enable = 'off';                              %Disable the trial table.
            run = 1;                                                        %Set the run variable back to 1.
            
        otherwise                                                           %For all other values 1 =< run < 2...
            new_data = handles.moto.read_stream();                          %Read in any new stream output.
            N = size(new_data,1);                                           %Find the number of new samples.
            if N > 0                                                        %If there was any new data in the stream.   
                new_data(:,2) = ...
                    handles.slope*(new_data(:,2) - handles.baseline);       %Apply the calibration constants to the primary data signal.
                force(1:end-N,:) = force(N+1:end,:);                        %Shift the existing force samples to make room for the new samples.
                force(end-N+1:end,:) = new_data(:,2);                       %Add the new samples to the force signal.
                sensors = new_data(N,2:4) >= [handles.force_thresh,...
                    handles.ir_thresh*[1,1]];                               %Grab the status of the pellet receivers.   
                StimBehavior_Update_Force_Plot(handles,...
                    force);                                                 %Update the force plot.
                StimBehavior_Update_Sensor_Diagrams(...
                    handles,sensors);                                       %Update the sensor diagrams.
%                 fprintf(1,'%1.0f\t%1.1f\t%1.0f\t%1.0f\n',new_data');        %Print the new data to the serial line.
            end             
            
    end
    
    drawnow;                                                                %Update the figure and execute any waiting callbacks.
end

try                                                                         %Attempt to stop the signal streaming.
    handles.moto.stream_enable(0);                                          %Disable streaming on the Arduino.
    handles.moto.clear();                                                   %Clear any residual values from the serial line.
    Add_Msg(handles.msgbox,[datestr(now,13) ' - Idle mode stopped.']);      %Show the user that the session has ended.
catch err                                                                   %If an error occured while closing the serial line...
    cprintf([1,0.5,0],'WARNING: %s\n',err.message);                         %Show the error message as a warning.
    str = ['\t<a href="matlab:opentoline(''%s'',%1.0f)">%s '...
        '(line %1.0f)</a>\n'];                                              %Create a string for making a hyperlink to the error-causing line in each function of the stack.
    for i = 2:numel(err.stack)                                              %Step through each script in the stack.
        cprintf([1,0.5,0],str,err.stack(i).file,err.stack(i).line,...
            err.stack(i).name, err.stack(i).line);                          %Display a jump-to-line link for each error-throwing function in the stack.
    end
    txt = MotoTrak_Save_Error_Report(handles,err);                          %Save a copy of the error in the AppData folder.
    MotoTrak_Send_Error_Report(handles,handles.err_rcpt,txt);               %Send an error report to the specified recipient.    
end