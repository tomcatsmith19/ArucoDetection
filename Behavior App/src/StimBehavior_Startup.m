function varargout = StimBehavior_Startup(varargin)

%
%StimBehavior_Startup.m - Vulintus, Inc.
%
%   StimBehavior_STARTUP runs when the task program is launched. It sets 
%   default directories, creates the GUI, loads the training stages, and 
%   connects to the  controller.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first created, adapted from
%       ST_Tactile_2AFC_Startup.m
%

close all force;                                                            %Close any open figures.
fclose all;                                                                 %Close any open data files.
delete(instrfind);                                                          %Delete any open serial objects.


%% Define program-wide constants.
global run                                                                  %Create the global run variable.
run = 1;                                                                    %Set the run variable to 1.
if nargin == 0                                                              %If there are no optional input arguments...
    handles = struct;                                                       %Create a handles structure.
    handles.sys_name = 'StimBehavior';                                      %Set the Vulintus system name to StimBehavior.
    handles.mainpath = Vulintus_Set_AppData_Path(handles.sys_name);         %Grab the expected directory for LED detection task application data.
    handles.version = 0.10;                                                 %Set the vibration task program version.
else                                                                        %Otherwise, the first optional input argument will be a handles structure.
    handles = varargin{1};                                                  %Grab the pre-existing handles structure.    
end
varargout = {};                                                             %Create a variable output argument cell array.
[~, temp] = system('hostname');                                             %Grab the local computer name.
temp(temp < 33) = [];                                                       %Kick out any spaces and carriage returns from the computer name.
handles.host = temp;                                                        %Save the local computer name.
handles.computer = getenv('COMPUTERNAME');                                  %Grab the computer name.


%% Create the main GUI.
handles = StimBehavior_Make_GUI(handles);                                   %Call the subfunction to make the GUI.
% set(handles.mainfig,'resize','on','ResizeFcn',@StimBehavior_Resize);     %Set the resize function for the vibration task main figure.
Vulintus_All_Uicontrols_Enable(handles.mainfig,'off');                      %Disable all of the uicontrols until the Arduino is connected.


%% Load the current configuration file.
if nargin == 0                                                              %If no pre-existing handles structure was passed to the startup function...
    handles = StimBehavior_Default_Config(handles);                         %Load the default configuration values.    
    temp = fullfile(handles.mainpath, '*stimbehavior.config');              %Set the expected filename of the configuration file.
    temp = dir(temp);                                                       %Find all matching configuration files in the main program path.
    if isempty(temp)                                                        %If no configuration file was found...
        filename = sprintf('%s_stimbehavior.config',...
            handles.computer);                                              %Create a filename.
        filename = fullfile(handles.mainpath,filename);                     %Add the main path to the filename.
        Vulintus_Behavior_Write_Config(filename, handles,...
            {'datapath','stage_url','stage_edit_url'});                     %Create a default configuration file.
    else                                                                    %Otherwise, if at least one configuration file was found...
        if length(temp) == 1                                                %If there's one configuration file in the main program path...
            handles.config_file = fullfile(handles.mainpath, temp(1).name); %Set the configuration file path to the single file.
        else                                                                %Otherwise, if there's multiple configuration files...
            temp = {temp.name};                                             %Create a cell array of configuration file names.
            i = listdlg('PromptString',...
                'Which configuration file would you like to use?',...
                'name','Multiple Configuration Files',...
                'SelectionMode','single',...
                'listsize',[300 200],...
                'initialvalue',1,...
                'uh',25,...
                'ListString',temp);                                         %Have the user pick a configuration file to use from a list dialog.
            if isempty(i)                                                   %If the user clicked "cancel" or closed the dialog...
                clear('run');                                               %Clear the global run variable from the workspace.
                return                                                      %Skip execution of the rest of the function.
            end
            handles.config_file = [handles.mainpath temp{i}];               %Set the configuration file path to the single file.
        end 
        placeholder = fullfile(handles.mainpath, 'temp_config.temp');       %Set the filename for the temporary placeholder file.
        handles = Vulintus_Behavior_Load_Config(handles,...
            handles.config_file, placeholder);                              %Call the function to the load the configuration file.
    end
    if handles.datapath(end) ~= '\'                                         %If the last character of the data path isn't a forward slash...
        handles.datapath(end+1) = '\';                                      %Add a forward slash to the end.
    end
    temp = find(handles.datapath == '\');                                   %Find all of the forward slashes in the filename.
    for i = temp                                                            %Step through each parent folder.
        if ~exist(handles.datapath(1:i),'dir')                              %If the specified folder in the data path doesn't already exist...
            mkdir(handles.datapath(1:i));                                   %Create the primary local data path.
        end
    end
end


%% Connect to the OmniTrak Controller.
handles.ardy = Connect_StimBehavior_Controller('listbox',handles.msgbox);   %Connect to the Arduino, passing the listbox handle to receive messages.
if isempty(handles.ardy)                                                    %If the connection failed...
    close(handles.mainfig);                                                 %Close the GUI.
    clear('run');                                                           %Clear the global run variable from the workspace.
    return                                                                  %Skip execution of the rest of the function.
end
Replace_Msg(handles.msgbox,...
    [datestr(now,13) ' - OmniTrak controller connected.']);                 %Show when the Arduino connection was successful in the messagebox.     
handles.moto.clear();                                                       %Clear any residual values from the serial line.
handles.booth = handles.moto.booth();                                       %Grab the booth number from the Arduino board.
port_list = Vulintus_Serial_Port_List;                                      %Grab all of the connected serial devices.
handles.dropport.Items = port_list(:,1);                                    %Update the port dropdown items.
handles.dropport.Value = handles.moto.port;                                 %Set the value of the port dropdown to the current port.


%% Load the training/testing stage information.
handles = StimBehavior_Read_Stages(handles);                                %Call the function to load the stage information.
if run == 0                                                                 %If the user cancelled an operation during stage selection...
    close(handles.mainfig);                                                 %Close the GUI.
    clear('run');                                                           %Clear the global run variable from the workspace.
    return                                                                  %Skip execution of the rest of the function.
end
handles.cur_stage = 1;                                                      %Set the current stage to the first stage in the list.
handles = StimBehavior_Load_Stage(handles);                                 %Load the stage parameters for current stage.


%% Load the previous subject list.
handles.subject_list = Vulintus_Load_Previous_Subjects(handles.sys_name,...
    handles.mainpath,handles.dropsubject);                                  %Call the function to load the previous subjects list.
handles.subject = handles.dropsubject.Value;                                %Set the current subject.


%% Pin the handles structure to the GUI and go into the main run loop.
guidata(handles.mainfig,handles);                                           %Pin the handles structure to the main figure.
if nargin == 0                                                              %If the function wasn't called by another function...
    try                                                                     %Attempt to run the program.        
        StimBehavior_Main_Loop(handles.mainfig);                            %Start the main loop.
    catch err                                                               %If any error occurs...
        Vulintus_Show_Error_Report('LED_Detection Task', err);              %Pop up a window showing the error.
        if ~ishandle(handles.mainfig)                                       %If the original figure was closed (i.e. during calibration)...
            figs = get(0,'children');                                       %Grab handles for all open figures.
            j = zeros(numel(figs),1);                                       %Create a matrix for checking which figure is the MotoTrak figure.
            for i = 1:numel(figs)                                           %Step through each open figure...
                j(i) = strncmpi(get(figs(i),'name'),...
                    'LED Detection Task',14);                               %Find the vibration task figure based on the name.
            end
            handles.mainfig = figs(j);                                      %Reset the main figure handle.         
        end        
        handles = guidata(handles.mainfig);                                 %Grab the handles structure from the main GUI.
        err_path = [handles.mainpath 'Error Reports\'];                     %Create the expected directory name for the error reports.
        txt = Vulintus_Behavior_Save_Error_Report(err_path,...
            'Tactile Discrimination',err,handles);                          %Save a copy of the error in the AppData folder.      
        if handles.enable_error_reporting ~= 0                              %If remote error reporting is enabled...
            Vulintus_Behavior_Send_Error_Report(handles,...
                handles.err_rcpt,txt);                                      %Send an error report to the specified recipient.     
        end
        Vulintus_Behavior_Close(handles.mainfig);                           %Call the function to close the vibration task program.
        errordlg(sprintf(['An fatal error occurred in the tactile '...
            'discrimination task program. An message containing the '...
            'error information has been sent to "%s", and a Vulintus '...
            'engineer will contact you shortly.'], handles.err_rcpt),...
            'Fatal Error in LED_Detection Task');                           %Display an error dialog.
    end
else                                                                        %Otherwise...
    varargout{1} = handles;                                                 %Return the handles structure as the first variable output argument.
end
