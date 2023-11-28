function handles = StimBehavior_Update_Controls_Within_Session(handles)

%
%StimBehavior_Update_Controls_Within_Session.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_UPDATE_CONTROLS_WITHIN_SESSION disables all of the 
%   uicontrol and uimenu objects that should not be active while the
%   StimBehavior task is running a behavioral session.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Update_Controls_Within_Session.m.
%

%Disable all uicontrol objects.
Vulintus_All_Uicontrols_Enable(handles.mainfig,'off');                      %Disable all of the uicontrols.

%Update the "Camera" uimenu.
handles.menu.camera.h.Enable = 'on';                                        %Enable the camera menu.
handles.menu.camera.view_webcam.MenuSelectedFcn = ...
    {@Vulintus_Set_Global_Run,2.3};                                         %Set the callback for the "View Webcam" option.
handles.menu.camera.view_webcam.Enable = 'on';                              %Enable the "View Webcam" option.

%Update the "Calibration" uimenu.
handles.menu.cal.h.Enable = 'on';                                           %Enable the calibration menu.
handles.menu.cal.reset_baseline.MenuSelectedFcn = ...
    {@Vulintus_Set_Global_Run,2.4};                                         %Set the callback for the "Reset Baseline" option.
handles.menu.cal.reset_baseline.Enable = 'on';                              %Enable the "Reset Baseline" option.

%Update the "Stages" uimenu.
handles.menu.stages.h.Enable = 'on';                                        %Enable the camera menu.
handles.menu.stages.view_spreadsheet.Enable = 'on';                         %Enable the "View Spreadsheet" option.

%Update the "Preferences" uimenu.
handles.menu.pref.h.Enable = 'on';                                          %Enable the preferences menu.
handles.menu.pref.open_datapath.Enable = 'on';                              %Enable the "Open Datapath" option.
handles.menu.pref.error_reports.Enable = 'on';                              %Enable the "View Error Reports" option.
handles.menu.pref.config_dir.Enable = 'on';                                 %Enable the "Configuration Files..." option.

%Enable the trial table.
handles.trialtable.Enable = 'on';                                           %Enable the trial table.
handles.trialtable.Data = {};                                               %Clear any existing data from the trial table.

%Enable the manual feed button.
handles.feedbutton.ButtonPushedFcn = {@Vulintus_Set_Global_Run,2.2};        %Set the Feed button callback.
handles.feedbutton.Enable = 'on';                                           %Enable the Feed button.

%Change the Start/Stop button to stop mode.
handles.startbutton.Text = 'STOP';                                          %Update the string on the Start/Stop button.
handles.startbutton.FontColor = [0.5 0 0];                                  %Update the string on the Start/Stop button.
handles.startbutton.ButtonPushedFcn = {@Vulintus_Set_Global_Run,1.0};       %Set the Start/Stop button callback.
handles.startbutton.Enable = 'on';                                          %Enable the Start/Stop button.

drawnow;                                                                    %Immediately update the figure.