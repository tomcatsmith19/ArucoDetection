function port = StimBehavior_Select_Serial_Port

%StimBehavior_Select_Serial_Port.m - Vulintus, Inc., 2016
%
%   STIMBEHAVIOR_SELECT_SERIAL_PORT detects available serial ports for
%   StimBehavior task setups and compares them to serial ports previously 
%   identified as being connected to StimBehavior task setups.
%
%   UPDATE LOG:
%   02/03/2022 - Drew Sloan - Function first created, adapted from
%       LED_Detection_Task_Select_Serial_Port.m.

[port, busyports] = Poll_Available_Ports;                                   %Grab all available ports.
    
while ~isempty(port) && length(port) > 1                                    %If there's more than one serial port available, loop until a LED task controller port is chosen.
    uih = 1.5;                                                              %Set the height for all buttons.
    w = 10;                                                                  %Set the width of the port selection figure.
    h = (numel(port) + 1)*(uih + 0.1) + 0.2 - 0.25*uih;                     %Set the height of the port selection figure.
    set(0,'units','centimeters');                                           %Set the screensize units to centimeters.
    pos = get(0,'ScreenSize');                                              %Grab the screensize.
    pos = [pos(3)/2-w/2, pos(4)/2-h/2, w, h];                               %Scale a figure position relative to the screensize.    
    fig1 = figure('units','centimeters',...
        'Position',pos,...
        'resize','off',...
        'MenuBar','none',...
        'name','Select A Serial Port',...
        'numbertitle','off');                                               %Set the properties of the figure.
    for i = 1:numel(port)                                                   %Step through each available serial port.
        if any(strcmpi(port{i},busyports))                                  %If the port is busy...
            txt = [port{i} ' (BUSY)'];                                      %Label the port as busy on the button.
        else                                                                %Otherwise...
            txt = [port{i} ' (IDLE)'];                                      %Label the port as idle on the button.
        end
        uicontrol(fig1,'style','pushbutton',...
            'string',txt,...
            'units','centimeters',...
            'position',[0.1 h-i*(uih+0.1) w-0.2 uih],...
            'fontweight','bold',...
            'fontsize',14,...
            'callback',['guidata(gcbf,' num2str(i) '); uiresume(gcbf);']);  %Make a button for the port showing that it is busy.
    end
    i = i + 1;                                                              %Increment the button counter.
    uicontrol(fig1,'style','pushbutton',...
        'string','Refresh List',...
        'units','centimeters',...
        'position',[3 h-i*(uih+0.1)+0.25*uih-0.1 3.8 0.75*uih],...
        'fontweight','bold',...
        'fontsize',12,...
        'foregroundcolor',[0 0.5 0],...
        'callback',['guidata(gcbf,' num2str(i) '); uiresume(gcbf);']);      %Make a button for the port showing that it is busy.
    uiwait(fig1);                                                           %Wait for the user to push a button on the pop-up figure.
    if ishandle(fig1)                                                       %If the user didn't close the figure without choosing a port...
        i = guidata(fig1);                                                  %Grab the index of chosen port name from the figure.
        close(fig1);                                                        %Close the figure.
        if i > numel(port)                                                  %If the user selected to refresh the list...
            [port, busyports] = Poll_Available_Ports;                       %Call the subfunction to check each available serial port for a LED task controller.
            if isempty(port)                                                %If no LED detection task controllers were found...
                errordlg(['ERROR: No LED detection task controllers were detected on '...
                    'this computer!'],'No LED detection task controllers!');          %Show an error in a dialog box.
                port = [];                                                  %Set the function output to empty.
                return                                                      %Skip execution of the rest of the function.
            end
        else                                                                %Otherwise...
            port = port(i);                                                 %Set the serial port to that chosen by the user.
        end        
    else                                                                    %Otherwise, if the user closed the figure without choosing a port...
       port = [];                                                           %Set the chosen port to empty.
    end
end

if ~isempty(port)                                                           %If a port was selected...
    port = port{1};                                                         %Convert the port cell array to a string.
    if strcmpi(busyports,port)                                              %If the selected serial port is busy...
        temp = instrfind('port',port);                                      %Grab the serial handle for the specified port.
        fclose(temp);                                                       %Close the busy serial connection.
        delete(temp);                                                       %Delete the existing serial connection.
    end
end


%% This subfunction steps through available serial ports to identify LED task controller connections.
function [port, busyports] = Poll_Available_Ports

waitbar = big_waitbar('title','Connecting to the LED task controller',...
    'string','Detecting serial ports...',...
    'value',0.33);                                                          %Create a waitbar figure.

port = instrhwinfo('serial');                                               %Grab information about the available serial ports.
if isempty(port)                                                            %If no serial ports were found...
    errordlg(['ERROR: There are no available serial ports on this '...
        'computer.'],'No Serial Ports!');                                   %Show an error in a dialog box.
    port = [];                                                              %Set the function output to empty.
    return                                                                  %Skip execution of the rest of the function.
end
busyports = setdiff(port.SerialPorts,port.AvailableSerialPorts);            %Find all ports that are currently busy.
port = port.SerialPorts;                                                    %Save the list of all serial ports regardless of whether they're busy.

if waitbar.isclosed()                                                       %If the user closed the waitbar figure...
    errordlg('Connection to LED task controller was cancelled by the user!',...
        'Connection Cancelled');                                            %Show an error.
    port = [];                                                              %Set the function output to empty.
    return                                                                  %Skip execution of the rest of the function.
end
waitbar.string('Identifying LED task controllers...');                      %Update the waitbar text.
waitbar.value(0.66);                                                        %Update the waitbar value.

key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB\';              %Set the registry query field.
[~, txt] = dos(['REG QUERY ' key ' /s /f "FriendlyName" /t "REG_SZ"']);     %Query the registry for all USB devices.
checker = zeros(numel(port),1);                                              %Create a check matrix to identify Arduino Unos.
for i = 1:numel(port)                                                       %Step through each port name.
    j = strfind(txt,['(' port{i} ')']);                                     %Find the port in the USB device list.
    if ~isempty(j)                                                          %If a matching port was found...
        if strcmpi(txt(j-18:j-2),'Arduino Mega 2560') || ...
                strcmpi(txt(j-18:j-2),'USB Serial Device')                  %If the device is an Arduino Uno or a SAMD21.
            checker(i) = 1;                                                 %Mark the device for inclusion.
        end
    end
end
port(checker == 0) = [];                                                    %Kick out all non-Arduino devices from the ports list.
busyports = intersect(port,busyports);                                      %Kick out all non-Arduino devices from the busy ports list.

if waitbar.isclosed()                                                       %If the user closed the waitbar figure...
    errordlg('Connection to LED task controller was cancelled by the user!',...
        'Connection Cancelled');                                            %Show an error.
    port = [];                                                              %Set the function output to empty.
    return                                                                  %Skip execution of the rest of the function.
end

waitbar.close();                                                            %Close the waitbar.
