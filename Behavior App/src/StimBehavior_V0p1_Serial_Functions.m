function ctrl = StimBehavior_V0p1_Serial_Functions(ctrl)

%StimBehavior_V0p1_Serial_Functions.m - Vulintus, Inc., 2022
%
%   STIMBEHAVIOR_V0P1_SERIAL_FUNCTIONS defines and adds the Arduino-based
%   serial communication functions to the "ctrl" structure.
%
%   UPDATE LOG:
%   02/03/2022 - Drew Sloan - Function first created, adapted from
%       LED_Detection_Task_V1p0_Serial_Functions.m.
%


serialcon = ctrl.serialcon;                                                 %Grab the handle for the serial connection.
serialcon.Timeout = 2;                                                      %Set the timeout for serial read/write operations, in seconds.

switch ctrl.serialcon.UserData                                              %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        while serialcon.BytesAvailable > 0                                  %If there's any junk leftover on the serial line...
            fread(serialcon,1,'uint8');                                     %Read each byte and discard it.
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        while serialcon.NumBytesAvailable > 0                               %If there's any junk leftover on the serial line...
            read(serialcon,1,'uint8');                                      %Read each byte and discard it.
        end
end

s = StimBehavior_Load_Serial_Codes;                                         %Load the serial block codes for the specified sketch version.

%Basic status functions.
ctrl.check_serial = @()v1p0_check_serial(serialcon);                        %Set the function for checking the serial connection.
ctrl.check_sketch = @()v1p0_simple_return(serialcon,s.SKETCH_VERIFY);       %Set the function for checking that the StimBehavior sketch is running.
ctrl.check_version = @()v1p0_simple_return(serialcon,s.GET_SKETCH_VER);     %Set the function for checking that the StimBehavior sketch is running.
ctrl.set_booth = ...
    @(int)v1p0_write_eeprom_uint16(serialcon,s,s.EEPROM_BOOTH_NUM,int);     %Set the function for setting the booth number saved on the controller.
ctrl.get_booth = ...
    @()v1p0_read_eeprom_uint16(serialcon,s,s.EEPROM_BOOTH_NUM);             %Set the function for returning the booth number saved on the controller.

%Output functions.
ctrl.feed = @()v1p0_simple_command(serialcon,s.TRIGGER_FEEDER);             %Set the function for immediately triggering a feeding.
ctrl.stop_feed = @()v1p0_simple_command(serialcon,s.STOP_FEED);             %Set the function for immediately stopping a feeding trigger.
ctrl.set_feed_dur = ...
    @(int)v1p0_send_uint16(serialcon,s.SET_FEED_TRIG_DUR,int,0);            %Set the function for setting the feeding/water trigger duration on the controller.
ctrl.get_feed_dur = ...
    @()v1p0_simple_return(serialcon,s.RETURN_FEED_TRIG_DUR);                %Set the function for checking the current feeding/water trigger duration on the controller.

%Tone commands.
ctrl.play_tone = @(i)v1p0_send_uint8(serialcon,s.PLAY_TONE,i,0);            %Set the function for immediate triggering of a tone.
ctrl.stop_tone = @()v1p0_simple_command(serialcon,s.STOP_TONE);             %Set the function for immediately silencing all tones.
ctrl.set_tone_index = ...
    @(i)v1p0_send_uint8(serialcon,s.SET_TONE_INDEX,i,0);                    %Set the function for setting the current tone index.
ctrl.get_tone_index = ...
    @()v1p0_simple_return(serialcon,s.RETURN_TONE_INDEX);                   %Set the function for checking the current tone index.
ctrl.set_tone_freq = ...
    @(int)v1p0_send_uint16(serialcon,s.SET_TONE_FREQ,int,0);                %Set the function for setting the frequency of a tone.
ctrl.get_tone_freq = ...
    @()v1p0_simple_return(serialcon,s.RETURN_TONE_FREQ);                    %Set the function for checking the current frequency of a tone.
ctrl.set_tone_dur = ...
    @(int)v1p0_send_uint16(serialcon,s.SET_TONE_DUR,int,0);                 %Set the function for setting the duration of a tone.
ctrl.get_tone_dur = ...
    @()v1p0_simple_return(serialcon,s.RETURN_TONE_DUR);                     %Set the function for checking the current duration of a tone.
% ctrl.get_max_num_tones = ...
%     @()v1p0_simple_return_uint8(serialcon,s.RETURN_MAX_TONES);              %Set the function for checking the maximum number of tones that can be set.

%Nosepoke commands.
ctrl.get_nosepoke = ...
    @()v1p0_simple_return(serialcon,s.RETURN_NOSEPOKE);                     %Set the function for checking the current pressure from the BMP280.

%Streaming functions.
ctrl.stream_enable = ...
    @(int)v1p0_stream_enable(serialcon,s.STREAM_ENABLE,int);                %Set the function for enabling or disabling the stream.
ctrl.read_stream = @()v1p0_read_stream(serialcon);                          %Set the function for reading values from the stream.
ctrl.clear = @()v1p0_clear_stream(serialcon);                               %Set the function for clearing the serial line prior to streaming.

%Housekeeping functions.
ctrl.close = @()v1p0_close_serialcon(serialcon);                            %Set the function for closing and deleting the serial connection.


%% This function checks the status of the serial connection.
function output = v1p0_check_serial(serialcon)
if isa(serialcon,'serial') && isvalid(serialcon) && ...
        (serialcon.UserData > 1 || strcmpi(get(serialcon,'status'),'open')) %Check the serial connection...
    output = 1;                                                             %Return an output of one.
    disp(['Serial port ''' serialcon.Port ''' is connected and open.']);    %Show that everything checks out on the command line.
else                                                                        %If the serial connection isn't valid or open.
    output = 0;                                                             %Return an output of zero.
    warning('CONNECT_STIMBEHAVIOR_CONTROLLER:NonresponsivePort',...
        'The serial port is not responding to status checks!');             %Show a warning.
end


%% This function sends a byte command without an expected reply.
function v1p0_simple_command(serialcon,cmd)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,cmd,'uint8');                                      %Send the command to the controller.
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,cmd,'uint8');                                       %Send the command to the controller.
end


%% This function sends a byte command and receives a character reply.
function [value, time] = v1p0_simple_return(serialcon,cmd)
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,cmd,'uint8');                                      %Send the command to the controller.
        pause(0.01);                                                        %Pause for 10 milliseconds.
        output = fscanf(serialcon,'%f')';                                   %Check the serial line for a reply.
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,cmd,'uint8');                                       %Send the command to the controller.
        pause(0.01);                                                        %Pause for 10 milliseconds.
        temp = readline(serialcon);                                         %Read in a line of text from the serial line.
        output = sscanf(temp,'%f')';                                        %Check the serial line for a reply.
end
if numel(output) ~= 3 || output(1) ~= cmd                                   %If the output is the requested output...
    output = [NaN, NaN, NaN];                                               %Return NaNs.
end
value = output(2);                                                          %Return the requested value first.
time = output(3);                                                           %Return the millisecond clock time second.


%% This function sends a byte command with a single uint8 argument.
function v1p0_send_uint8(serialcon,cmd,int,dummy_bytes)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,cmd,'uint8');                                      %Send the command to the controller.
        fwrite(serialcon,int,'uint8');                                      %Send the uint8 argument.
        for i = 1:dummy_bytes                                               %Step through any dummy bytes.
            fwrite(serialcon,0,'uint8');                                    %Send a dummy byte to advance the command queue.
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,cmd,'uint8');                                       %Send the command to the controller.
        write(serialcon,int,'uint8');                                       %Send the uint8 argument.
        for i = 1:dummy_bytes                                               %Step through any dummy bytes.
            write(serialcon,0,'uint8');                                     %Send a dummy byte to advance the command queue.
        end
end


%% This function sends a byte command with a single uint16 argument.
function v1p0_send_uint16(serialcon,cmd,int,dummy_bytes)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,cmd,'uint8');                                      %Send the command to the controller.
        fwrite(serialcon,int,'uint16');                                     %Send the uint16 argument.
        for i = 1:dummy_bytes                                               %Step through any dummy bytes.
            fwrite(serialcon,0,'uint8');                                    %Send a dummy byte to advance the command queue.
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,cmd,'uint8');                                       %Send the command to the controller.
        write(serialcon,int,'uint16');                                      %Send the uint16 argument.
        for i = 1:dummy_bytes                                               %Step through any dummy bytes.
            write(serialcon,0,'uint8');                                     %Send a dummy byte to advance the command queue.
        end
end


%% This function reads a uint16 out of the controller's EEPROM.
function output = v1p0_read_eeprom_uint16(serialcon,s,addr)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,s.READ_2BYTES_EEPROM,'uint8');                     %Send the command to the controller.
        fwrite(serialcon,addr,'uint16');                                    %Send the uint16 EEPROM address to the controller.
        fwrite(serialcon,0,'uint16');                                       %Send a dummy uint16 value to the controller to push back the reply uint16.
        timeout = now + 1/86400;                                            %Set the reply timeout duration (100 milliseconds).
        while serialcon.BytesAvailable < 2 && now < timeout                 %Loop until there's a reply or the operating times out.
            pause(0.001);                                                   %Pause for 1 millisecond.
        end
        if serialcon.BytesAvailable >= 2                                    %If the controller replied...
            output = fread(serialcon,1,'uint16');                           %Read the reply from the serial line as an unsigned 16-bit integer.
        else                                                                %Otherwise...
            output = [];                                                    %Create a variable to hold the output.
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,s.READ_2BYTES_EEPROM,'uint8');                      %Send the command to the controller.
        write(serialcon,addr,'uint16');                                     %Send the uint16 argument.
        write(serialcon,0,'uint16');                                        %Send a dummy uint16 value to the controller to push back the reply uint16.        
        timeout = now + 1/86400;                                            %Set the reply timeout duration (100 milliseconds).
        while serialcon.NumBytesAvailable < 2 && now < timeout              %Loop until there's a reply or the operating times out.
            pause(0.001);                                                   %Pause for 1 millisecond.
        end
        if serialcon.NumBytesAvailable >= 2                                 %If the controller replied...
            output = read(serialcon,1,'uint16');                            %Read the reply from the serial line as an unsigned 16-bit integer.
        else                                                                %Otherwise...
            output = [];                                                    %Create a variable to hold the output.
        end
end


%% This function writes a uint16 to the controller's EEPROM.
function v1p0_write_eeprom_uint16(serialcon,s,addr,int)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,s.SAVE_2BYTES_EEPROM,'uint8');                     %Send the command to the controller.
        fwrite(serialcon,addr,'uint16');                                    %Send the uint16 EEPROM address to the controller.
        fwrite(serialcon,int,'uint16');                                     %Send a dummy uint16 value to the controller to push back the reply uint16.
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,s.SAVE_2BYTES_EEPROM,'uint8');                      %Send the command to the controller.
        write(serialcon,addr,'uint16');                                     %Send the uint16 EEPROM address to the controller.
        write(serialcon,int,'uint16');                                      %Send a dummy uint16 value to the controller to push back the reply uint16.
end


%% This function reads a uint16 out of the controller's EEPROM.
function output = v1p0_read_eeprom_uint32(serialcon,s,addr)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,s.READ_4BYTES_EEPROM,'uint8');                     %Send the command to the controller.
        fwrite(serialcon,addr,'uint16');                                    %Send the uint16 EEPROM address to the controller.
        fwrite(serialcon,0,'uint32');                                       %Send a dummy uint32 value to the controller to push back the reply uint16.
        timeout = now + 1/86400;                                            %Set the reply timeout duration.
        while serialcon.BytesAvailable < 4 && now < timeout                 %Loop until there's a reply or the operating times out.
            pause(0.001);                                                   %Pause for 1 millisecond.
        end
        if serialcon.BytesAvailable >= 4                                    %If the controller replied...
            output = fread(serialcon,1,'uint32');                           %Read the reply from the serial line as an unsigned 32-bit integer.
        else                                                                %Otherwise...
            output = [];                                                    %Create a variable to hold the output.
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,s.READ_4BYTES_EEPROM,'uint8');                      %Send the command to the controller.
        write(serialcon,addr,'uint16');                                     %Send the uint16 EEPROM address to the controller.
        write(serialcon,0,'uint32');                                        %Send a dummy uint32 value to the controller to push back the reply uint16.
        timeout = now + 1/86400;                                            %Set the reply timeout duration.
        while serialcon.NumBytesAvailable < 4 && now < timeout              %Loop until there's a reply or the operating times out.
            pause(0.001);                                                   %Pause for 1 millisecond.
        end
        if serialcon.NumBytesAvailable >= 4                                 %If the controller replied...
            output = read(serialcon,1,'uint32');                            %Read the reply from the serial line as an unsigned 32-bit integer.
        else                                                                %Otherwise...
            output = [];                                                    %Create a variable to hold the output.
        end
end


%% This function writes a uint32 to the controller's EEPROM.
function v1p0_write_eeprom_uint32(serialcon,s,addr,int)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,s.SAVE_2BYTES_EEPROM,'uint8');                     %Send the command to the controller.
        fwrite(serialcon,addr,'uint16');                                    %Send the uint16 EEPROM address to the controller.
        fwrite(serialcon,int,'uint32');                                     %Send a dummy uint16 value to the controller to push back the reply uint32.
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,s.SAVE_2BYTES_EEPROM,'uint8');                      %Send the command to the controller.
        write(serialcon,addr,'uint16');                                     %Send the uint16 EEPROM address to the controller.
        write(serialcon,int,'uint32');                                      %Send a dummy uint16 value to the controller to push back the reply uint32.
end



%% This function reads a float32 out of the controller's EEPROM.
function output = v1p0_read_eeprom_float32(serialcon,s,addr)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,s.READ_4BYTES_EEPROM,'uint8');                     %Send the command to the controller.
        fwrite(serialcon,addr,'uint16');                                    %Send the uint16 EEPROM address to the controller.
        fwrite(serialcon,0,'uint32');                                       %Send a dummy uint32 value to the controller to push back the reply float32.
        timeout = now + 1/86400;                                            %Set the reply timeout duration.
        while serialcon.BytesAvailable < 4 && now < timeout                 %Loop until there's a reply or the operating times out.
            pause(0.001);                                                   %Pause for 1 millisecond.
        end
        if serialcon.BytesAvailable >= 4                                    %If the controller replied...
            bytes = fread(serialcon,4,'uint8');                             %Read the reply from the serial line as a 4 unsigned bytes.
            output = double(typecast(uint8(bytes),'single'));               %Cast the 4 unsigned bytes back into a floating-point number.
        else                                                                %Otherwise...
            output = [];                                                    %Create a variable to hold the output.
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,s.READ_4BYTES_EEPROM,'uint8');                      %Send the command to the controller.
        write(serialcon,addr,'uint16');                                     %Send the uint16 EEPROM address to the controller.
        write(serialcon,0,'uint32');                                        %Send a dummy uint32 value to the controller to push back the reply float32.
        timeout = now + 1/86400;                                            %Set the reply timeout duration.
        while serialcon.NumBytesAvailable < 4 && now < timeout              %Loop until there's a reply or the operating times out.
            pause(0.001);                                                   %Pause for 1 millisecond.
        end
        if serialcon.NumBytesAvailable >= 4                                 %If the controller replied...
            bytes = read(serialcon,4,'uint8');                              %Read the reply from the serial line as a 4 unsigned bytes.
            output = double(typecast(uint8(bytes),'single'));               %Cast the 4 unsigned bytes back into a floating-point number.
        else                                                                %Otherwise...
            output = [];                                                    %Create a variable to hold the output.
        end
end


%% This function writes a float32 to the controller's EEPROM.
function v1p0_write_eeprom_float32(serialcon,s,addr,val)     
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        fwrite(serialcon,s.SAVE_4BYTES_EEPROM,'uint8');                     %Send the command to the controller.
        fwrite(serialcon,addr,'uint16');                                    %Send the uint16 EEPROM address to the controller.
        bytes = typecast(single(val),'uint8');                              %Cast the floating-point value to 4 unsigned bytes.
        for i = 1:4                                                         %Step through each byte.
            fwrite(serialcon,bytes(i),'uint8');                             %Send the 32-bit floating point number to the controller.
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        write(serialcon,s.SAVE_4BYTES_EEPROM,'uint8');                      %Send the command to the controller.
        write(serialcon,addr,'uint16');                                     %Send the uint16 EEPROM address to the controller.
        bytes = typecast(single(val),'uint8');                              %Cast the floating-point value to 4 unsigned bytes.
        for i = 1:4                                                         %Step through each byte.
            write(serialcon,bytes(i),'uint8');                              %Send the 32-bit floating point number to the controller.
        end
end


%% This function enables/disables streaming.
function v1p0_stream_enable(serialcon,cmd,enable_val)
if enable_val > 0                                                           %If streaming is being enabled...
    v1p0_clear_stream(serialcon);                                           %Clear any bytes currently on the stream.
end
v1p0_send_uint8(serialcon,cmd,enable_val,0);                                %Call the function to set the streaming state on the controller.


%% This function reads in the values from the data stream when streaming is enabled.
function output = v1p0_read_stream(serialcon)
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        timeout = now + 50/86400000;                                        %Set the following loop to timeout after 50 milliseconds.
        while serialcon.BytesAvailable == 0 && now < timeout                %Loop until there's a reply on the serial line or there's 
            pause(0.001);                                                   %Pause for 1 millisecond to keep from overwhelming the processor.
        end
        output = [];                                                        %Create an empty matrix to hold the serial line reply.
        while serialcon.BytesAvailable > 0                                  %Loop as long as there's bytes available on the serial line...
            try
                streamdata = fscanf(serialcon,'%f')';                       %Read in the incoming data.
                output(end+1,:) = streamdata(1:3);                          %Read each byte and save it to the output matrix.
            catch err                                                       %If there was a stream read error...
                warning('LED_Detection_Task:StreamingError',...
                    ['StimBehavior STREAM READ WARNING: ',...
                    err.identifier]);                                       %Show that a stream read error occured.
            end
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        timeout = now + 50/86400000;                                        %Set the following loop to timeout after 50 milliseconds.
        while serialcon.NumBytesAvailable == 0 && now < timeout             %Loop until there's a reply on the serial line or there's 
            pause(0.001);                                                   %Pause for 1 millisecond to keep from overwhelming the processor.
        end
        output = [];                                                        %Create an empty matrix to hold the serial line reply.
        while serialcon.NumBytesAvailable > 0                               %Loop as long as there's bytes available on the serial line...
            try
                temp = readline(serialcon);                                 %Read in the incoming data.
                streamdata = sscanf(temp,'%f')';                            %Convert the text to numbers.
                output(end+1,:) = streamdata(1:3);                          %Read each byte and save it to the output matrix.
            catch err                                                       %If there was a stream read error...
                warning('LED_Detection_Task:StreamingError',...
                    ['StimBehavior STREAM READ WARNING: ',...
                    err.identifier]);                                       %Show that a stream read error occured.
            end
        end
end


%% This function clears any remaining values from the serial line.
function v1p0_clear_stream(serialcon)
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...
        timeout = now + 50/86400000;                                        %Set the reply timeout duration (50 milliseconds).
        while serialcon.BytesAvailable == 0 && now < timeout                %Loop for the timeout duration or until there's bytes available on the serial line.
            pause(0.001);                                                   %Pause for 1 millisecond to keep from overwhelming the processor.
        end
        while serialcon.BytesAvailable > 0                                  %Loop as long as there's bytes available on the serial line...
            fread(serialcon,1,'uint8');                                     %Read each byte and discard it.
        end
    case 2                                                                  %If the Matlab version is 2020b or younger...
        timeout = now + 50/86400000;                                        %Set the reply timeout duration (50 milliseconds).
        while serialcon.NumBytesAvailable == 0 && now < timeout             %Loop for the timeout duration or until there's bytes available on the serial line.
            pause(0.001);                                                   %Pause for 1 millisecond to keep from overwhelming the processor.
        end
        while serialcon.NumBytesAvailable > 0                               %Loop as long as there's bytes available on the serial line...
            read(serialcon,1,'uint8');                                      %Read each byte and discard it.
        end
end


%% This function closes the serial connection and deletes the serial object.
function v1p0_close_serialcon(serialcon)
switch serialcon.UserData                                                   %Switch between the types of serial interfaces.
    case 1                                                                  %If the Matlab version is older than 2020b...        
        fclose(serialcon);                                                  %Close the serial connection.
    case 2                                                                  %If the Matlab version is 2020b or younger...
        flush(serialcon);                                                   %Clear the input and output buffers.
end
delete(serialcon);                                                          %Delete the serial object.