function StimBehavior_Manual_Feed(fid, handles, session)

%
%StimBehavior_Manual_Feed.m - Vulintus, Inc.
%
%   STIMBEHAVIOR_MANUAL_FEED triggers a manual feeding and writes the 
%   timing data to a StimBehavior task session's *.OmniTrak file.
%   
%   UPDATE LOG:
%   10/06/2021 - Drew Sloan - Function first implemented, adapted from
%       ST_Tactile_2AFC_Task_Manual_Feed.m.
%

%Trigger the feeding.
handles.moto.feed();                                                        %Trigger a feeding through the MotoTrak controller.

%Write the feeding time to file.
fwrite(fid, handles.block_codes.SWUI_MANUAL_FEED, 'uint16');                %Write the software manual feed block code to the file.
fwrite(fid, 1, 'uint8');                                                    %Write a dispenser index of 1 to the file.
fwrite(fid, now, 'float64');                                                %Write the serial date number to the file as a 64-bit floating point.
fwrite(fid, 1, 'uint16');                                                   %Write the number of feedings to the file.

%Print a message to the messagebox.
str = sprintf('%s - Manual Feeding (%1.0f total feedings).',...
    datestr(now,13), session.feedings);                                     %Create a message string.
Add_Msg(handles.msgbox, str);                                               %Show the message in the message box.