function ctrl = Connect_StimBehavior_Controller(varargin)

%Connect_StimBehavior_Controller.m - Vulintus, Inc., 2022
%
%   CONNECT_STIMBEHAVIOR_CONTROLLER establishes the serial connection 
%   between the computer and the OmniTrak controller, and sets the
%   communications functions used for streaming data.
%
%   UPDATE LOG:
%   02/03/2022 - Drew Sloan - Function first created, adapted from
%       Connect_StimBehavior_Controller.m.
%

port = [];                                                                  %Create a variable to hold the serial port.
listbox = [];                                                               %Create a matrix to hold a listbox handle.
ax = [];                                                                    %Create a matrix to hold an axes handle.

%Step through the optional input arguments and set any user-specified parameters.
str = {'port','listbox','axes'};                                            %List the optional input arguments.
for i = 1:2:length(varargin)                                                %Step through the optional input arguments
	if ~ischar(varargin{i}) || ~any(strcmpi(str,varargin{i}))               %If the first optional input argument isn't one of the expected property names...
        cprintf('err',['ERROR IN ' upper(mfilename) ':  Property name '...
            'not recognized! Optional input properties are:\n']);           %Show an error.
        for j = 1:length(str)                                               %Step through each optional input argument name.
            cprintf('err',['\t''' str{j} '''\n']);                          %Print the optional input argument name.
        end
        beep;                                                               %Beep to alert the user to an error.
        ctrl = [];                                                          %Set the function output to empty.
        return                                                              %Skip execution of the rest of the function.
    else                                                                    %Otherwise...
        temp = varargin{i};                                                 %Grab the parameter name.
        switch lower(temp)                                                  %Switch among possible parameter names.
            case 'port'                                                     %If the parameter name was "port"...
                port = varargin{i+1};                                       %Use the specified serial port.
            case 'listbox'                                                  %If the parameter name was "listbox"...
                listbox = varargin{i+1};                                    %Save the listbox handle to write messages to.
                if ~ishandle(listbox) && ...
                        ~strcmpi(get(listbox,'type'),'listbox')             %If the specified handle is not a listbox...
                    error(['ERROR IN ' upper(mfilename) ': The '...
                        'specified ListBox handle is invalid.']);           %Show an error.
                end 
            case 'axes'                                                     %If the parameter name was "axes"...
            	ax = varargin{i+1};                                         %Save the axes handle to write messages to.
                if ~ishandle(ax) && ~strcmpi(get(ax,'type'),'axes')         %If the specified handle is not a listbox...
                    error(['ERROR IN ' upper(mfilename) ': The '...
                        'specified axes handle is invalid.']);              %Show an error.
                end
        end
    end
end

[~, local] = system('hostname');                                            %Grab the local computer name.
local(local < 33) = [];                                                     %Kick out any spaces and carriage returns from the computer name.
if isempty(port)                                                            %If no port was specified...
    port = StimBehavior_Select_Serial_Port;                                 %Call the port selection function.
else                                                                        %Otherwise...
    temp = instrfind('port',port);                                          %Check to see if the specified port is busy...
    if ~isempty(temp)                                                       %If an existing serial connection was found for this port...
        i = questdlg(['Serial port ''' port ''' is busy. Reset and use '...
            'this port?'],['Reset ''' port '''?'],...
            'Reset','Cancel','Reset');                                      %Ask the user if they want to reset the busy port.
        if strcmpi(i,'Cancel')                                              %If the user selected "Cancel"...
            port = [];                                                      %...set the selected port to empty.
        else                                                                %Otherwise, if the user pressed "Reset"...
            fclose(temp);                                                   %Close the busy serial connection.
            delete(temp);                                                   %Delete the existing serial connection.
        end
    end
end

if isempty(port)                                                            %If no port was selected.
    warning('Connect_StimBehavior_Controller:NoPortChosen',['No serial '...
        'port chosen for Connect_StimBehavior_Controller. Connection '...
        'to the controller was aborted.']);                                 %Show a warning.
    ctrl = [];                                                              %Set the function output to empty.
    return;                                                                 %Exit the ArdyMotorBoard function.
end

if ~isempty(listbox) && ~isempty(ax)                                        %If both a listbox and an axes are specified...
    ax = [];                                                                %Clear the axes handle.
    warning(['WARNING IN CONNECT_STIMBEHAVIOR_CONTROLLER: Both a '...
        'listbox and an axes handle were specified. The axes handle '...
        'will be ignored.']);                                               %Show a warning.
end

message = 'Connecting to the OmniTrak controller...';                       %Create the beginning of message to show the user.
t = 0;                                                                      %Create a dummy handle for a text label.
if ~isempty(listbox)                                                        %If the user specified a listbox...    
    set(listbox,'string',message,'value',1,'listboxtop',1);                 %Show the Arduino connection status in the listbox.
elseif ~isempty(ax)                                                         %If the user specified an axes...
    t = text(mean(xlim(ax)),mean(ylim(ax)),message,...
        'horizontalalignment','center',...
        'verticalalignment','middle',...
        'fontweight','bold',...
        'margin',5,...
        'edgecolor','k',...
        'backgroundcolor','w',...
        'parent',ax);                                                       %Create a text object on the axes.
    temp = get(t,'extent');                                                 %Grab the extent of the text object.
    temp = temp(3)/range(xlim(ax));                                         %Find the ratio of the text length to the axes width.
    set(t,'fontsize',0.6*get(t,'fontsize')/temp);                           %Scale the fontsize of the text object to fit the axes.
else                                                                        %Otherwise...
    waitbar = big_waitbar('title','Connecting to LED Detection Task',...
        'string',['Connecting to ' port '...'],...
        'value',0.25);                                                      %Create a waitbar figure.
    temp = 0.05;                                                            %Create an initial waitbar value.
end

try                                                                         %Try to open the serial port for communication.
    if datenum(version('-date')) >= 738098                                  %If the version is 2020b or newer...        
        serialcon = serialport(port,115200);                                %Set up the serial connection on the specified port.
        serialcon.UserData = 2;                                             %Set the serial port interface version number to 2.
    else                                                                    %Otherwise...
        serialcon = serial(port,'baudrate',115200);                         %Set up the serial connection on the specified port.
        serialcon.UserData = 1;                                             %Set the serial port interface version number to 1.
        fopen(serialcon);                                                   %Open the serial port.
    end
catch err                                                                   %If no connection could be made to the serial port...
    delete(serialcon);                                                      %Delete the serial object.
    error(['ERROR IN CONNECT_STIMBEHAVIOR_CONTROLLER: Could not open a '...
        'serial connection on port ''' port '''.']);                        %Show an error.
end

timeout = now + 10/86400;                                                   %Set a time-out point for the following loop.
while now < timeout                                                         %Loop for 10 seconds or until the Arduino initializes.
    switch serialcon.UserData                                               %Switch between the types of serial interfaces.
        case 1                                                              %If the Matlab version is older than 2020b...
            N = serialcon.BytesAvailable;                                   %Grab the number of available bytes on the serial line.
        case 2                                                              %If the Matlab version is 2020b or younger...
            N = serialcon.NumBytesAvailable;                                %Grab the number of available bytes on the serial line.
    end
    if N > 0                                                                %If there's bytes available on the serial line...
        break                                                               %Break out of the waiting loop.
    else                                                                    %Otherwise...
        message(end+1) = '.';                                               %Add a period to the end of the message.
        if ~isempty(ax) && ishandle(t)                                      %If progress is being shown in text on an axes...
            set(t,'string',message);                                        %Update the message in the text label on the figure.
        elseif ~isempty(listbox)                                            %If progress is being shown in a listbox...
            set(listbox,'string',message,'value',[],'listboxtop',1);        %Update the message in the listbox.
        else                                                                %Otherwise, if progress is being shown in a waitbar...
            temp = 1 - 0.9*(1-temp);                                        %Increment the waitbar values.
            waitbar.value(temp);                                            %Update the waitbar value.
        end
        pause(0.5);                                                         %Pause for 500 milliseconds.
    end
end

ctrl = struct('port',port,'serialcon',serialcon);                           %Create the output structure for the serial communication.
ctrl = StimBehavior_V0p1_Serial_Functions(ctrl);                            %Load the serial communication functions.

pause(4);                                                                   %Pause for 4 seconds.
ctrl.clear();                                                               %Clear off the serial line.
temp = ctrl.check_sketch();                                                 %Grab the sketch ID from the serial connections.
if temp ~= 123                                                              %If the correct reply wasn't received...
    delete(serialcon);                                                      %...delete the serial object and show an error.
    error(['ERROR IN CONNECT_STIMBEHAVIOR_CONTROLLER: Could not '...
        'connect to the controller. Check to make sure the controller '...
        'is connected to ' port ' and that it is running the correct '...
        'LED Detection Task sketch.']);                                     %Show an error.
else                                                                        %Otherwise...
    message = 'Controller Connected!';                                      %Add to the message to show that the connection was successful.
    if ~isempty(ax) && ishandle(t)                                          %If progress is being shown in text on an axes...
        set(t,'string',message);                                            %Update the message in the text label on the figure.
    elseif ~isempty(listbox)                                                %If progress is being shown in a listbox...
        set(listbox,'string',message,'value',[],'listboxtop',1);            %Update the message in the listbox.
    else                                                                    %Otherwise, if progress is being shown in a waitbar...
        waitbar.value(1);                                                   %Update the waitbar value.
        waitbar.string(message);                                            %Update the message in the waitbar.
    end
    fprintf(1,'%s\n',['The LED Detection Task controller is connected '...
        'and the LED Detection Task sketch is detected as running.']);      %Show that the connection was successful.
end

pause(1);                                                                   %Pause for one second.
if ~isempty(ax) && ishandle(t)                                              %If progress is being shown in text on an axes...
    delete(t);                                                              %Delete the text object.
elseif isempty(listbox)                                                     %If progress is being shown in a waitbar...
    waitbar.close();                                                        %Close the waitbar.
end

ctrl.clear();                                                               %Clear the serial line.