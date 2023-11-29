function Vulintus_Behavior_Close(fig)

%
%Vulintus_Behavior_Close.m - Vulintus, Inc.
%
%   VULINTUS_BEHAVIOR_CLOSE executes after the main behavioral loop
%   terminates, usually because the user closes the figure window.
%   
%   UPDATE LOG:
%   11/30/2021 - Drew Sloan - Function converted to a Vulintus behavior
%       toolbox function, adapted from Tactile_Discrimination_Task_Close.m.
%

handles = guidata(fig);                                                     %Grab the handles structure from the main GUI.

if isfield(handles,'moto')                                                  %If the handles structure has a field called "moto"...    
    handles.moto.stream_enable(0);                                          %Double-check that streaming on the Arduino is disabled.
    handles.moto.clear();                                                   %Clear any leftover stream output.
    if handles.moto.serialcon.UserData == 1                                 %If the Matlab version is older than 2020b...
        fclose(handles.moto.serialcon);                                     %Close the serial connection to the Arduino.
    end
    delete(handles.moto.serialcon);                                         %Delete the serial connection to the Arduino.
end

delete(fig);                                                                %Delete the main figure.