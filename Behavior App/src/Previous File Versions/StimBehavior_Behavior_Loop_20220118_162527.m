function StimBehavior_Behavior_Loop(fig)

%
%StimBehavior_Behavior_Loop.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_BEHAVIOR_LOOP is the main behavioral loop for the 
%   StimBehavior task program.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Behavior_Loop.m.
%

global run                                                                  %Create the global run variable.

handles = guidata(fig);                                                     %Grab the handles structure from the main GUI.

%Clear the GUI.
handles = StimBehavior_Update_Controls_Within_Session(handles);             %Disable all of the uicontrols and uimenus during the session.
Clear_Msg([],[],handles.msgbox);                                            %Clear the existing messages out of the messagebox.

%Initialize various session tracking variables.
session = StimBehavior_Initialize_Session(handles);                         %Call the subfunction to initialize the session.
temp = StimBehavior_Load_Previous_Performance(handles);                     %Load this subject's previous performance.   
session.counts(2:end,:) = session.counts(2:end,:) + temp(2:end,:);          %Add the historical counts to the current tracking matrix.        
handles = StimBehavior_Create_Session_Plots(handles, session);              %Initialize the session plots.
trial = struct('start_time',[],'end_time',[],'status_flag',ones(1,4));      %Create a structure to hold trial parameters.
% pause_text = 0;                                                             %Create a variable to hold a text handle for a pause label.
% errstack = zeros(1,3);                                                      %Create a matrix to prevent duplicate error-reporting.

%Create the output data file.
handles.block_codes = Load_OmniTrak_File_Block_Codes(1);                    %Load the OmniTrak file format block code libary.
[session.fid, ~] = StimBehavior_Write_File_Header(handles);                 %Use the Write File Header subfunction to start an OmniTrak vile.

%Set the controller parameters for this session.
handles.moto.clear();                                                       %Clear any residual values from the serial line.  
handles.moto.stream_enable(1);                                              %Enable periodic streaming on the MotoTrak controller.


%% MAIN LOOP ***********************************************************************************************************************
while fix(run) == 2                                                         %Loop until the user ends the session.
    
%WAIT FOR THE SUBJECT TO RELEASE THE CAROUSEL **************************************************************************************
    trial.start_time = [];                                                  %Reset the trial start time to go into idle mode.
    while trial.status_flag(2) && run == 2                                  %Loop until no carousel touch is detected...
        [trial, session] = ...
            StimBehavior_Check_Signal(handles, session, trial);             %Check for any new samples on the serial line.
        pause(0.005);                                                       %Pause for 5 milliseconds.
    end  
    
%PREPARE THE NEXT TRIAL ************************************************************************************************************
    session.trial_num = session.trial_num  + 1;                             %Increment the trial counter.
    trial = StimBehavior_Reset_Trial(handles, session, trial);              %Reset the trial.    
    
%WAITING FOR TRIAL INITIATION ******************************************************************************************************
    while ~trial.status_flag(2) && run == 2                                 %Loop until a carousel touch is detected...
        [trial, session] = ...
            StimBehavior_Check_Signal(handles, session, trial);             %Check for any new samples on the serial line.
        pause(0.005);                                                       %Pause for 5 milliseconds.
    end
    
%START THE TRIAL *******************************************************************************************************************
    if run == 2                                                             %If a manual feed wasn't triggered...        
        trial = StimBehavior_Start_Trial(handles,session,trial);            %Initialize the trial variables.
%         trial = StimBehavior_Create_Trial_Plot(handles, session, trial); %Create a plot showing a trial diagram.        
    end
    
%MONITOR THE TRIAL *****************************************************************************************************************
    while trial.status_flag(1) && now < trial.end_time && run == 2          %Loop until the carousel is released or the end of the trial...
        [trial, session] = ...
            StimBehavior_Check_Signal(handles, session, trial);             %Check for any new samples on the serial line.
        pause(0.005);                                                       %Pause for 5 milliseconds.
    end
    
%RECORD TRIAL RESULTS **************************************************************************************************************
    switch run                                                              %Switch between the recognized run cases.
        
        case 2.0                                                            %If the session is still running as normal...            
            [session, trial] = ...
                StimBehavior_Update_Session(handles, session, trial);       %Calculate the trial outcome and display it.
            StimBehavior_Write_Trial_Data(handles, session, trial);         %Write the trial data to file.       
            
        case 2.2                                                            %If the user wants to manually feed.
            session.feedings = session.feedings + 1;                        %Increment the feedings count.
            Vulintus_Behavior_Manual_Feed(session.fid,...
                handles.block_codes.SWUI_MANUAL_FEED, handles.moto, 1,...
                handles.msgbox, session.feedings);                          %Call the toolbox function to trigger and record a feeding.
            session.trial_num = session.trial_num - 1;                      %Decrement the trial counter.
            run = 2;                                                        %Reset the run variable to 2.0.
            
        case 2.3                                                            %If the user wants to open a webcam preview...    
            Vulintus_Behavior_Launch_Webcam_Preview;                        %Call the toolbox function to launch a webcam preview.
            run = 2;                                                        %Reset the run variable to 2.0.
    end           
    
    drawnow;                                                                %Update the figure and execute any waiting callbacks.
    
end
    
fclose(session.fid);                                                        %Close the session data file.

%Stop the data stream.
try                                                                         %Attempt to clear the serial line.
    handles.moto.stream_enable(0);                                          %Disable streaming on the MotoTrak controller.
    handles.moto.clear();                                                   %Clear any residual values from the serial line.
catch err                                                                   %If an error occurred...
    txt = StimBehavior_Save_Error_Report(handles,err);                      %Save a copy of the error in the AppData folder.
    StimBehavior_Send_Error_Report(handles,handles.err_rcpt,txt);           %Send an error report to the specified recipient.
end

str = sprintf('%s - Session ended, %1.0f total feedings.',...
    datestr(now,13),session.feedings);                                      %Create a session ending message.
Replace_Msg(handles.msgbox,str);                                            %Show the user that the session has ended.

Vulintus_All_Uicontrols_Enable(handles.mainfig,'off');                      %Disable all of the uicontrols.

guidata(handles.mainfig,handles);                                           %Pin the handles structure to the main figure.