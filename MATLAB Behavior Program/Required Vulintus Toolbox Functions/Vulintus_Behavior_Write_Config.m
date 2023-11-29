function Vulintus_Behavior_Write_Config(filename, handles, fields)

%
%Vulintus_Behavior_Write_Config.m - Vulintus, Inc.
%
%   This function create a *.config file linking the specificed 
%   customizable behavioral parameters ("fields") stored in a configuration
%   structure ("handles") to currently-set values.
%   
%   UPDATE LOG:
%   10/05/2021 - Drew Sloan - Function first created, adapted from
%       LED_Detection_Task_Write_Config.m.
%



[fid, errmsg] = fopen(filename,'wt');                                       %Create a new configuration file.
if fid == -1                                                                %If a file could not be created...    
    error(['ERROR in LED_DETECTION_TASK_WRITE_CONFIG: Could not create '...
        'configuration file:\n\t%s\n\n\t%s'],filename, errmsg);             %Throw an error.
end

if ~isempty(fields)                                                         %If the fields input isn't empty...
    if ~iscell(fields)                                                      %If the fields input isn't a cell array...
        fields = {fields};                                                  %Convert the fields input to a cell array.
    end
    for f = 1:length(fields)                                                %Step through each field.
        if ~ischar(fields{f})                                               %If the field value isn't a character array...
            warning(['A non-character field input in the '...
                'configuration file write function was ignored.']);         %Show a warning.
        elseif ~any(strcmpi(fieldnames(handles),fields{f}))                 %If the field value doesn't match any fields in the handles structure..
            warning(['The specified field "' fields{f} '"  isn''t '...
                'a recognized field of the handles structure, '...
                'it will be ignored by the configuration file '...
                'write function']);                                         %Show a warning.
        else                                                                %Otherwise...
            temp = upper(fields{f});                                        %Grab the specified field name.
            temp(temp == '_') = ' ';                                        %Replace all underscores with spaces.
            fprintf(fid,'%s: ',temp);                                       %Print the field name to the configuration file.
            val = handles.(fields{f});                                      %Grab the value of the specified handles field.
            if ischar(val)                                                  %If the value is a string...
                fprintf(fid,'%s\n',val);                                    %Print the value to the configuration file.
            elseif isnumeric(val)                                           %If the value is numeric...
                if numel(val) > 1                                           %If there's more than one value...
                    fprintf(fid,'[');                                       %Print a left bracket to the configuration file.
                    for i = 1:numel(val)                                    %Step through each value...
                        fprintf(fid,'%s',num2str(val(i)));                  %Print each value as a string.
                        if i < numel(val)                                   %If this isn't the last value.
                            fprintf(fid,' ');                               %Print a space to the configuration file.
                        end
                    end
                    fprintf(fid,']\n');                                     %Print a right bracket and carriage return to the configuration file.
                else                                                        %Otherwise...
                    fprintf(fid,'%s\n',num2str(val));                       %Print the value and a carriage return to the configuration file.
                end
            end
        end
    end
end
fclose(fid);                                                                %Close the configuration file.