function [fid,filename] = StimBehavior_Write_File_Header(handles)

%   STIMBEHAVIOR_WRITE_FILE_HEADER writes the file header for StimBehavior
%   task session data files using Vulintus' *.OmniTrak format.
%   
%   UPDATE LOG:
%   01/18/2022 - Drew Sloan - Function first created, adapted from
%       ST_Tactile_2AFC_Write_File_Header.m.
%

if ~exist(handles.datapath,'dir')                                           %If the main data folder doesn't already exist...
    mkdir(handles.datapath);                                                %Create the main data folder on the C:\ drive.
end
path = fullfile(handles.datapath,handles.subject);                          %Create the subfolder name for this rat.
if ~exist(path,'dir')                                                       %If the subject subfolder doesn't already exist...
    mkdir(path);                                                            %Create the subject subfolder.
end
date_string = datestr(now,30);                                              %Create a timestamp string.
temp = handles.stage(handles.cur_stage).number;                             %Grab the stage number.
if ~ischar(temp)                                                            %If the stage number isn't already a string...
    temp = num2str(temp);                                                   %Convert the stage number to a string.
end
temp(temp == '.') = 'p';                                                    %Replace any periods in the stage name with a "p".
temp = ['Stage' temp];                                                      %Add the word "Stage" to the stage string.
filename = [handles.subject '_' date_string '_TACTILE_' temp '.OmniTrak'];  %Create the new filename.
Add_Msg(handles.msgbox,[datestr(now,13) ' - Writing session data to '...
    'file:']);                                                              %Print a message showing the user that the filename will follow.
Add_Msg(handles.msgbox,['          ' path]);                                %Show the user the session data path.
Add_Msg(handles.msgbox,['          ' filename]);                            %Show the user the session data file name.
filename = fullfile(path,filename);                                         %Add the path to the filename.
[fid,errmsg] = fopen(filename,'w');                                         %Open the data file as a binary file for writing.
if fid == -1                                                                %If the file could not be created...
    errordlg(sprintf(['Could not create the session data file '...
        'at:\n\n%s\n\nError:\n\n%s'],filename,...
        errmsg),'Tactile Discrimination Task File Write Error');            %Show an error dialog box.
end

ofbc = handles.block_codes;                                                 %Copy the block codes to an easier-to-handle structure.

%File format verification and version.
fwrite(fid,ofbc.OMNITRAK_FILE_VERIFY,'uint16');                             %The first block of the file should equal 0xABCD to indicate a Vulintus *.OmniTrak file.
fwrite(fid,ofbc.FILE_VERSION,'uint16');                                     %The second block of the file should be the file version indicator.
fwrite(fid,ofbc.CUR_DEF_VERSION,'uint16');                                  %Write the current file version.

%System information.
fwrite(fid,ofbc.SYSTEM_TYPE,'uint16');                                      %Write the block indicating the Vulintus system type.
fwrite(fid,5,'uint8');                                                      %Write a value of 5 to indicate the base system is SensiTrak.
fwrite(fid,ofbc.COMPUTER_NAME,'uint16');                                    %Write the block indicating the computer name.
fwrite(fid,length(handles.host),'uint8');                                   %Write the number of characters in the computer name.
fwrite(fid,handles.host,'uchar');                                           %Write the characters of the computer name.
temp = handles.booth;                                                       %Grab the booth name.
if ~ischar(temp)                                                            %If the booth name isn't already a string...
    temp = num2str(temp);                                                   %Convert the booth name to a string.
end
fwrite(fid,ofbc.USER_SYSTEM_NAME,'uint16');                                 %Write the user system name (i.e. booth number) block code.
fwrite(fid,length(temp),'uint8');                                           %Write the number of characters in the booth name.
fwrite(fid,temp,'uchar');                                                   %Write the characters of the booth name.
fwrite(fid,ofbc.COM_PORT,'uint16');                                         %Write the COM port block code.
fwrite(fid,length(handles.moto.port),'uint8');                              %Write the number of characters in the COM port name.
fwrite(fid,handles.moto.port,'uchar');                                      %Write the characters of the COM port name.
fwrite(fid,ofbc.TIME_ZONE_OFFSET,'uint16');                                 %Write the time zone offset block code.
dt = datenum(datetime('now','TimeZone','local')) - ...
    datenum(datetime('now','TimeZone','UTC'));                              %Calculate the different between the computer time and UTC time.
fwrite(fid,dt,'float64');                                                   %Write the time zone offset as a serial date number.


%Session information.
fwrite(fid,ofbc.CLOCK_FILE_START,'uint16');                                 %Write the file start serial date number block code.
fwrite(fid,now,'float64');                                                  %Write the current serial date number.
fwrite(fid,ofbc.EXP_NAME,'uint16');                                         %Write the experiment name block code.
fwrite(fid,length('Tactile Discrimination Task'),'uint16');                 %Write the number of characters in the experiment name.
fwrite(fid,'Tactile Discrimination Task','uchar');                          %Write the characters of the experiment name.
fwrite(fid,ofbc.SUBJECT_NAME,'uint16');                                     %Write the subject name block code.
fwrite(fid,length(handles.subject),'uint16');                               %Write the number of characters in the subject name.
fwrite(fid,handles.subject,'uchar');                                        %Write the characters of the subject name.
temp = handles.stage(handles.cur_stage).number;                             %Grab the stage number.
if ~ischar(temp)                                                            %If the stage number isn't already a string...
    temp = num2str(temp);                                                   %Convert the stage number to a string.
end
fwrite(fid,ofbc.STAGE_NAME,'uint16');                                       %Write the stage name block code.
fwrite(fid,length(temp),'uint16');                                          %Write the number of characters in the stage name.
fwrite(fid,temp,'uchar');                                                   %Write the characters of the stage name.
fwrite(fid,ofbc.STAGE_DESCRIPTION,'uint16');                                %Write the stage description block code.
fwrite(fid,length(handles.stage(handles.cur_stage).description),'uint16');  %Write the number of characters in the stage description.
fwrite(fid,handles.stage(handles.cur_stage).description,'uchar');           %Write the characters of the stage description.