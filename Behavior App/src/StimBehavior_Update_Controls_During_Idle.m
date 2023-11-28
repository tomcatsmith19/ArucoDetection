function handles = StimBehavior_Update_Controls_During_Idle(handles)

%
%StimBehavior_Update_Controls_During_Idle.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_UPDATE_CONTROLS_DURING_IDLE enables all of the uicontrol 
%   and uimenu objects that should be active while the StimBehavior task is 
%   idling between behavioral sessions.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Update_Controls_During_Idle.m.
%

%Update the figure callbacks.
handles.mainfig.CloseRequestFcn = {@Vulintus_Set_Global_Run,0};             %Set the callback for when the user tries to close the GUI.

%Update the "Stages" uimenu.
handles.menu.stages.view_spreadsheet.ButtonDownFcn = ...
    {@Vulintus_Open_Google_Spreadsheet,handles.stage_edit_url};             %Set the callback for the "Open Spreadsheet" submenu option.

%Update the "Calibration" uimenu.
handles.menu.cal.reset_baseline.MenuSelectedFcn = ...
    {@Vulintus_Set_Global_Run,1.4};                                         %Set the callback for the the "Reset Baseline" option.
handles.menu.cal.open_calibration.MenuSelectedFcn = ...
    {@Vulintus_Set_Global_Run,3.0};                                         %Set the callback for the the "Open Calibration" option.

%Update the "Preferences" uimenu.
handles.menu.pref.open_datapath.MenuSelectedFcn = ...
    {@Vulintus_Open_Directory,handles.datapath};                            %Set the callback for the "Open Data Directory" submenu option.
handles.menu.pref.set_datapath.MenuSelectedFcn = ...
    @Vulintus_Behavior_Set_Datapath;                                        %Set the callback for the "Set Data Directory" submenu option.
set([handles.menu.pref.err_report_on,handles.menu.pref.err_report_off],...
    'MenuSelectedFcn',@Vulintus_Behavior_Set_Error_Reporting);              %Set the callback for turning off/on automatic error reporting.
handles.menu.pref.error_reports.MenuSelectedFcn = ...
    {@Vulintus_Behavior_Open_Error_Reports,handles.mainpath};               %Set the callback for opening the error reports directory.
handles.menu.pref.config_dir.MenuSelectedFcn = ...
    {@Vulintus_Open_Directory,handles.mainpath};                            %Set the callback for opening the configuration directory.

%Update the "Camera" uimenu.
handles.menu.camera.view_webcam.MenuSelectedFcn = ...
    {@Vulintus_Set_Global_Run,1.5};                                         %Set the callback for the "View Webcam" option.

%Update the manual feed button.
handles.feedbutton.ButtonPushedFcn = {@Vulintus_Set_Global_Run,1.3};        %Set the callback for the Manual Feed button.

%Update the Start/Stop button.
handles.startbutton.Text = 'START';                                         %Set the text on the Start/Stop button.
handles.startbutton.FontColor = [0 0.5 0];                                  %Set the font color Start/Stop buttonto dark green.
handles.startbutton.ButtonPushedFcn = {@Vulintus_Set_Global_Run,2.0};       %Set the callback for the Start/Stop button.

%Update the dropdown callbacks.
handles.dropsubject.ValueChangedFcn = ...
    {@Vulintus_Behavior_Select_Subject,'SensiTrak'};                        %Set the callback for the subject drop-down menu.
handles.dropstage.ValueChangedFcn = {@Vulintus_Set_Global_Run,1.1};         %Set the callback for the stage selection drop-down menu.

%Update the pause button.
handles.pausebutton.ButtonPushedFcn = {@Vulintus_Set_Global_Run,2.2};       %Set the callback for the Pause button.

%Enable all uicontrol objects.
Vulintus_All_Uicontrols_Enable(handles.mainfig,'on');                       %Enable all of the uicontrols.

%Disable the pause button.
handles.pausebutton.Enable = 'off';                                         %Disable the pause button.

%Disable the trial table if unused.
data = handles.trialtable.Data;                                             %Grab the data from the trial table.
if isempty(data)                                                            %If there's no data yet...
    handles.trialtable.Enable = 'off';                                      %Disable the trial table.
end

drawnow;                                                                    %Immediately update the figure.