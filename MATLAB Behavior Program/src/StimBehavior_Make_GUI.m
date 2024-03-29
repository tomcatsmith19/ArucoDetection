function handles = StimBehavior_Make_GUI(handles)

%
%StimBehavior_Make_GUI.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_MAKE_GUI creates the graphical user interface (GUI) used 
%   by the StimBehavior task program.
%   
%   UPDATE LOG:
%   10/05/2021 - Drew Sloan - Function first created, adapted from
%      ST_Tactile_2AFC_Task_Make_GUI.m
%


%% Set the common properties of subsequent uicontrols.
fontsize = 16;                                                              %Set the fontsize for all uicontrols.
ui_h = 0.75;                                                                %Set the height of all editboxes and listboxes, in centimeters.
sp = 0.1;                                                                   %Set the spacing between uicontrols, in centimeters.
label_color = [0.7 0.7 0.9];                                                %Set the color for all labels.
handles.label = [];                                                         %Create a field to hold labels.


%% Create the main figure.
set(0,'units','centimeters');                                               %Set the system units to centimeters.
pos = get(0,'ScreenSize');                                                  %Grab the system screen size.
w = 20;                                                                     %Set the initial GUI width, in centimeters.
h = 14;                                                                     %Set the initial GUI height, in centimeters.
temp = sprintf('StimBehavior Task (V%1.2f)', handles.version);              %Create a string showing the task program version number.
handles.mainfig = uifigure('units','centimeter',...
    'Position',[pos(3)/2-w/2, pos(4)/2-h/2, w, h],...
    'resize','off',...
    'name',temp);                                                           %Create the main figure.
handles.mainfig.Units = 'pixels';                                           %Change the figure units to pixels.
pos = handles.mainfig.Position;                                             %Grab the figure position, in pixes.
scale = pos(3)/w;                                                           %Calculate the centimeters to pixels conversion factor.


%% Reset any handles already existing in the structure.
handles.label = [];                                                         %Reset the handles for the labels.


%% Create a stages menu at the top of the figure.
handles.menu.stages.h = uimenu(handles.mainfig,'label','Stages');           %Create a stages menu at the top of the LED_Detection_Task figure.
handles.menu.stages.view_spreadsheet = uimenu(handles.menu.stages.h,...
    'label','View Spreadsheet in Browser...',...
    'enable','off',...
    'separator','on');                                                      %Create a submenu option for opening the stages spreadsheet.
handles.menu.stages.set_spreadsheet = uimenu(handles.menu.stages.h,...
    'label','Set Spreadsheet URL...',...
    'enable','off');                                                        %Create a submenu option for setting the stages spreadsheet URL.
handles.menu.stages.reload_spreadsheet = uimenu(handles.menu.stages.h,...
    'label','Reload Spreadsheet',...
    'enable','off');                                                        %Create a submenu option for reloading the stages spreadsheet.


%% Create a calibration menu at the top of the figure.
handles.menu.cal.h = uimenu(handles.mainfig,'label','Calibration');         %Create a calibration menu at the top of the MotoTrak figure.
handles.menu.cal.reset_baseline = uimenu(handles.menu.cal.h,...
    'label','Reset Baseline',...
    'enable','off');                                                        %Create a submenu option for resetting the baseline.
handles.menu.cal.open_calibration = uimenu(handles.menu.cal.h,...
    'label','Open Calibration...',...
    'enable','off');                                                        %Create a submenu option for opening the calibration window.


%% Create a preferences menu at the top of the figure.
handles.menu.pref.h = uimenu(handles.mainfig,'label','Preferences');        %Create a preferences menu at the top of the LED_Detection_Task figure.
handles.menu.pref.open_datapath = uimenu(handles.menu.pref.h,...
    'label','Open Data Directory',...
    'enable','off');                                                        %Create a submenu option for opening the target data directory.
handles.menu.pref.set_datapath = uimenu(handles.menu.pref.h,...
    'label','Set Data Directory',...
    'enable','off');                                                        %Create a submenu option for setting the target data directory.
handles.menu.pref.err_report = uimenu(handles.menu.pref.h,...
    'label','Automatic Error Reporting',...
    'enable','off',...
    'separator','on');                                                      %Create a submenu option for tuning Automatic Error Reporting on/off.
handles.menu.pref.err_report_on = ...
    uimenu(handles.menu.pref.err_report,...
    'label','On',...
    'enable','off',...
    'checked','on');                                                        %Create a sub-submenu option for tuning Automatic Error Reporting on.
handles.menu.pref.err_report_off = ...
    uimenu(handles.menu.pref.err_report,...
    'label','Off',...
    'enable','off',...
    'checked','off');                                                       %Create a sub-submenu option for tuning Automatic Error Reporting on.
handles.menu.pref.error_reports = uimenu(handles.menu.pref.h,...
    'label','View Error Reports',...
    'enable','off');                                                        %Create a submenu option for opening the error reports directory.
handles.menu.pref.config_dir = uimenu(handles.menu.pref.h,...
    'label','Configuration Files...',...
    'enable','off',...
    'separator','on');                                                      %Create a submenu option for opening the configuration files directory.


%% Create a camera menu at the top of the figure.
handles.menu.camera.h = uimenu(handles.mainfig,'label','Camera');           %Create a camera menu at the top of the LED_Detection_Task figure.
handles.menu.camera.view_webcam = uimenu(handles.menu.camera.h,...
    'label','Open Webcam Window',...
    'enable','on');                                                         %Create a submenu option for opening a webcam window.
        

%% Create a panel housing all of the session information uicontrols.
ph = 2*(ui_h + sp) + 2*sp;                                                  %Set the panel height.
pw = w - 2*sp;                                                              %Set the panel width.
py = h - ph - sp;                                                           %Set the panel bottom edge.
p = uipanel(handles.mainfig,'units','pixels',...
    'position',scale*[sp, py, pw, ph],...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'backgroundcolor',get(handles.mainfig,'color'));                        %Create the panel to hold the session information uicontrols.

pos = [sp, sp, 2.25, ui_h];                                                 %Set the label position.
handles.label(end+1) = uilabel(p,'text','COM Port: ',...
    'position',scale*pos);                                                  %Make a static text label for the booth.
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left-hand edge for the booth drop-down.
pos(3) = 3.5;                                                               %Set the width of the booth drop-down.
handles.dropport = uidropdown(p,'editable','off',...
    'items',{'---'},...
    'position',scale*pos,...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'backgroundcolor','w',...
    'enable','off');                                                        %Create an drop-down for selecting the booth.
    
pos = [sp, 2*sp + ui_h, 2.25, ui_h];                                        %Set the label position.
handles.label(end+1) = uilabel(p,'text','Subject: ',...
    'position',scale*pos);                                                  %Make a static text label for the subject.
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left-hand edge for the subject drop-down.
pos(3) = 3.5;                                                               %Set the width of the subject drop-down.
handles.dropsubject = uidropdown(p,'editable','off',...
    'items',{'<Add New Subject>','<Edit Subject List>','[Bench Test]'},...
    'position',scale*pos,...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'backgroundcolor','w',...
    'enable','off');                                                        %Create an drop-down for selecting the subject name.

pos = handles.dropport.Position/scale;                                      %Grab the position of the booth drop-down.
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left-hand edge for the subject drop-down.
pos(3) = 3.75;                                                              %Set the width of the label.
handles.label(end+1) = uilabel(p,'text','Min. Touch Dur.: ',...
    'position',scale*pos);                                                  %Make a static text label for the sampling time.
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left-hand edge for the sampling time editbox.
pos(3) = 3.0;                                                               %Set the width of the sampling time editbox
handles.editdur = uieditfield(p,'editable','off',...
    'value','-',...
    'position',scale*pos,...
    'fontname','Arial',...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'horizontalalignment','center',...
    'backgroundcolor','w',...
    'enable','off');                                                        %Create an editbox for displaying the sampling time.

pos(1) = pos(1) + pos(3) + sp;                                              %Set the left edge of a label.
pos(3) = 3.0;                                                               %Set the width of a label.
handles.label(end+1) = uilabel(p,'text','Task Mode: ',...
    'position',scale*pos);                                                  %Make a static text label for each uicontrol.
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left edge of the task mode editbox.
pos(3) = pw - sp - pos(1);                                                  %Set the width of the task mode editbox.
handles.editmode = uieditfield(p,'editable','off',...
    'value','-',...
    'position',scale*pos,...
    'fontname','Arial',...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'horizontalalignment','center',...
    'backgroundcolor','w',...
    'enable','off');                                                        %Create an editbox for displaying the sampling time.

pos = handles.dropsubject.Position/scale;                                   %Grab the position of the subject drop-down.
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left-hand edge for the subject drop-down.
pos(3) = 2;                                                                 %Set the width of the label.
handles.label(end+1) = uilabel(p,'text','Stage: ',...
    'position',scale*pos);                                                  %Make a static text label for the stage
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left edge of the task mode editbox.
pos(3) = pw - sp - pos(1);                                                  %Set the width of the task mode editbox.
handles.dropstage = uidropdown(p,'editable','off',...
    'items',{'-'},...
    'position',scale*pos,...
    'fontname','Arial',...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'backgroundcolor','w',...
    'enable','off');                                                        %Create an drop-down for selecting the stage.

set(handles.label,'fontname','Arial',...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'horizontalalignment','right',...
    'verticalalignment','center',...
    'backgroundcolor',label_color);                                         %Set the properties for all the labels.

    
%% Create axes for displaying the touch sensor.
ax_h = 6;                                                                   %Set the total axes height.
py = py - ax_h - 2*sp;                                                      %Set the axes bottom edge.
pos = [2*sp, py, 6, (ax_h - sp)/2];                                         %Set the position for the force axes.
handles.force_ax = axes('parent',handles.mainfig,...
    'units','centimeters',...
    'position',pos,...
    'xtick',[],...
    'ytick',[],...
    'box','on');                                                            %Create axes to show the force signal.
disableDefaultInteractivity(handles.force_ax);                              %Disable the axes interactivity.
handles.force_ax.Toolbar.Visible = 'off';                                   %Hide the axes toolbar.
pos(2) = pos(2) + pos(4) + sp;                                              %Set the bottom edge of the poke/carousel sensor axes.
handles.sensor_ax = axes('parent',handles.mainfig,...
    'units','centimeters',...
    'position',pos,...
    'xtick',[],...
    'ytick',[],...
    'box','on');                                                            %Create axes to show the force sensor signal.
disableDefaultInteractivity(handles.sensor_ax);                             %Disable the axes interactivity.
handles.sensor_ax.Toolbar.Visible = 'off';                                  %Hide the axes toolbar.
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left edge of the psychophysical axes.
pos(2) = py;                                                                %Set the bottom edge of the axes.
pos(3) = w - pos(1) - 2*sp;                                                 %Set the width of the axes.
pos(4) = ax_h;                                                              %Set the height of the axes.
handles.psych_ax = axes('parent',handles.mainfig,...
    'units','centimeters',...
    'position',pos,...
    'xtick',[],...
    'ytick',[],...
    'box','on');                                                            %Create axes to show the psychophysical curve.
disableDefaultInteractivity(handles.psych_ax);                              %Disable the axes interactivity.
handles.psych_ax.Toolbar.Visible = 'off';                                   %Hide the axes toolbar.


%% Create pushbuttons for starting, stopping, pausing, and manually triggering feedings.
ui_h = (py - 4*sp)/3;                                                       %Recalculate the uicontrol height.
pos = [sp, sp, 3, ui_h];                                                    %Set the button position.
handles.feedbutton = uibutton(handles.mainfig,'text','FEED',...
    'position',scale*pos,...
    'fontname','Arial',...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'fontcolor','k',...
    'enable','off');                                                        %Create a button for manual feeds.
pos(2) = pos(2) + pos(4) + sp;                                              %Adjust the position bottom edge.    
handles.pausebutton = uibutton(handles.mainfig,'text','PAUSE',...
    'position',scale*pos,...
    'fontname','Arial',...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'fontcolor',[0 0 0.5],...
    'enable','off');                                                        %Create a pause button.
pos(2) = pos(2) + pos(4) + sp;                                              %Adjust the position bottom edge.    
handles.startbutton = uibutton(handles.mainfig,'text','START',...
    'position',scale*pos,...
    'fontname','Arial',...
    'fontweight','bold',...
    'fontsize',fontsize,...
    'fontcolor',[0 0.5 0],...
    'enable','off');                                                        %Create a pause button.


%% Create a table to show users trial data.
pos(1) = pos(1) + pos(3) + sp;                                              %Set the left-hand edge of the trial table.
pos(2) = sp;                                                                %Set the bottom edge of the trial table.
pos(3) = w - pos(1) - 2*sp;                                                 %Set the width of the trial table.
pos(4) = py - 3*sp - 1.5;                                                   %Set the height of the trial table.
handles.trialtable = uitable(handles.mainfig,'position',scale*pos,...
    'fontname','Arial',...
    'fontsize',0.75*fontsize,...
    'enable','off');                                                        %Create a table to hold trial info.
columns = {'Trial','Time','Pad','Outcome','Target','Choice',...
    'HT (s)','TT (s)','RT (s)'};                                            %List the column labels.
handles.trialtable.ColumnName = columns;                                    %Label the columns of the table.
col_w = {1, 1.5, 1, 1.5, 1.25, 1.25, 1.5, 1.5, 2};                          %Create a matrix to hold column widths.
N = sum(vertcat(col_w{:}));                                                 %Find the total of all the column widths.
for i = 1:numel(columns)                                                    %Step through each column label.
    col_w{i} = scale*pos(3)*col_w{i}/N;                                     %Scale each column width to the character size.
end
col_w{end} = 'auto';                                                        %Set the last column to auto-scale.
handles.trialtable.ColumnWidth = col_w;                                     %Set the column widths.            
handles.table_style = [];                                                   %Create a field to hold table styles.
handles.table_style.outcomes = 'HMFCANL';                                   %Create a subfield to hold table style labels.
handles.table_style.h(1) = uistyle('BackgroundColor',[0.5 1 0.6]);          %Create a light green cell color for hits.
handles.table_style.h(2) = uistyle('BackgroundColor',[1 0.6 0.5]);          %Create a light red cell color for misses.
handles.table_style.h(3) = uistyle('BackgroundColor',[1 0.5 0.6]);          %Create a light red cell color for false alarms.
handles.table_style.h(4) = uistyle('BackgroundColor',[0.6 1 0.5]);          %Create a light green cell color for correct rejections.
handles.table_style.h(5) = uistyle('BackgroundColor',[0.8 0.8 0.8]);        %Create a light gray cell color for aborts.
handles.table_style.h(6) = uistyle('BackgroundColor',[0.95 1 0.5]);         %Create a light yellow cell color for non-responses.
handles.table_style.h(7) = uistyle('BackgroundColor',[1 0.95 0.5]);         %Create a light yellow cell color for loiters.
s = uistyle('HorizontalAlignment','center');                                %Create a centered horicontal alignment style.
addStyle(handles.trialtable,s);                                             %Add the centered style to the table.


%% Create a text area to show users status messages.
pos(2) = pos(2) + pos(4) + sp;                                              %Set the bottom edge of the messagebox.
pos(4) = py - pos(2) - sp;                                                  %Set the height of the the messagebox.
handles.msgbox = uitextarea(handles.mainfig,...
    'value','Initializing...',...
    'position',scale*pos,...
    'fontname','Arial',...
    'fontweight','bold',...
    'fontsize',0.8*fontsize,...
    'editable','off');                                                      %Create a messagebox.


% %% Set the units for all children of the main figure to "normalized".
% objs = get(handles.mainfig,'children');                                     %Grab the handles for all children of the main figure.
% checker = ones(1,numel(objs));                                              %Create a checker variable to control the following loop.
% while any(checker == 1)                                                     %Loop until no new children are found.
%     for i = 1:numel(objs)                                                   %Step through each object.
%         if isempty(get(objs(i),'children'))                                 %If the object doesn't have any children.
%             checker(i) = 0;                                                 %Set the checker variable entry for this object to 0.
%         end
%     end
%     if any(checker == 1)                                                    %If any objects were found to have children...        
%         temp = get(objs(checker == 1),'children');                          %Grab the handles of the newly-identified children.
%         checker(:) = 0;                                                     %Skip all already-registed objects on the next loop.
%         temp = vertcat(temp{:});                                            %Vertically concatenate all of the object handles.
%         j = strcmpi(get(temp,'type'),'uimenu');                             %Check if any of the children are uimenu objects.
%         temp(j) = [];                                                       %Kick out all uimenu objects.        
%         if ~isempty(temp)                                                   %If there's any new objects...
%             for i = 1:numel(temp)                                           %Step through each new object.
%                 objs(end+1) = temp(i);                                      %Add each new child to the object list.
%                 checker(end+1) = 1;                                         %Add a new entry to the checker matrix.
%             end
%         end
%     end
% end
% type = get(objs,'type');                                                    %Grab the type of each object.
% objs(strcmpi(type,'uimenu')) = [];                                          %Kick out all uimenu items.
% set(objs,'units','normalized');                                             %Set all units to normalized.
