function amplitude = ICMSandCapture(ChN, charge, choice, layer, exp_name, attempt, trial, layer1, layer2, layer3, layer4, layer5, layer6)

% Stimulation Parameters
NRep = 208; % Number of pulses in stim train
Rate = 320; % Stimulating frequency (Hz)
pulse_width = 200; % Pulse width (us)
interphase_delay = 40; % Interphase delay (us)
pw_conv = pulse_width/1000; % Pulse width for conversion between charge and current
amplitude = round(charge/pw_conv); % current/amplitude (uA)
Param = [-1*amplitude, amplitude, pulse_width, pulse_width, interphase_delay]; % biphasic squared waveform pattern parameters
ParamZero = [0,0,0,0,0]; % set pattern parameters to 0 for layer choice (allows you to select what channels will be stimulated or not)
channelMat = zeros(6,3,10);
LayerNumArray = [string(layer1),string(layer2),string(layer3),string(layer4),string(layer5),string(layer6)];

for x = 1:length(LayerNumArray)
    channelMat(x,1,1) = x;
    y = count(LayerNumArray(x),","); % count the number of delimiters in a layer
    if y == 0 && strcmpi(LayerNumArray(x),"0") == 1
        channelMat(x,2,1) = 0;
    else 
        channelMat(x,2,1) = y+1;

        LayerArray = split(LayerNumArray(x),",");
        for v = 1:length(LayerArray)
            LayerArray2(v) = str2double(LayerArray(v));
        end
        for z = 1:length(LayerArray2)
            channelMat(x,3,z) = LayerArray2(z);
        end
    end
end


%% Setup oscilloscope

% Establish connection with oscilloscope
fprintf('Connecting to oscilloscope...\n');

% Find a VISA-USB object using Open Choice Instrument Manager
v = instrfind('Type', 'visa-usb', 'RsrcName', 'USB::0x0699::0x0368::C017166::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(v)
    v = visa('tek', 'USB::0x0699::0x0368::C017166::INSTR');
else
    fclose(v);
    v = v(1);
end
v.InputBufferSize = 100000;
% Connect to instrument object, obj1.
fopen(v);
fprintf('Connected to oscilloscope...\n');
% Ensure ASCII encoding so the data output makes sense
fprintf(v,'DATA:ENC ASCI');
fprintf(v, 'ACQuire:MODe SAMple');


%% Setup stimulator and stimulate

% Initializes all available stimulators and places them in stimulation mode (versus Z test mode).
err = PS_InitAllStim();
    switch err
        case 1
            disp('Error Initializing Devices');
        case 2
            disp('No Stimulators Found');
        otherwise
            disp('stimuluators where initialized correctly');
    end

% Gets number of available stimulators. The maximum number of stimulators you can work with is four.
[N, err] = PS_GetNStim();
    switch err
        case 0
            disp('Number of stimulators available:');
            disp(N);
            StimN = 1; % since we only have one stimulator, we just set the chosen stimulator to 1
        otherwise
            disp('Error finding stimulators');
    end

% Returns maximum number of channels (ChN) for the stimulator StimN and error code (err)
% StimN - stimulator number to get number of channels (starts from 1).
[NCh, err] = PS_GetNChannels(StimN);
    switch err
        case 0
            disp('Number of channels available:');
            disp(NCh);
        otherwise
            disp('Error finding channels for chosen stimulator');
    end

% Selects one channel for display on the voltage and current monitor connectors for the stimulator StimN.
% StimN - stimulator number to monitor (starts from 1)
% ChN - channel to monitor (starts from 1)
err = PS_SetMonitorChannel(StimN, ChN);
    switch err
        case -1
            disp('Invalid arguments error when setting monitor channel');
        case 1
            disp('Stimulator device error when setting monitor channel');
        otherwise
            disp('Monitor channel was set correctly');
    end   




% if user wants all channels to be stimulated
if strcmpi(choice,'All')==1

    % Set stimulation parameters for each channel in array
    for ch = 1:NCh
        % Sets number of repetitions - the number of times that the bi-phasic pulse or the arbitrary waveform
        % (loaded from a text file) is repeated for channel ChN. Default value is 1.
        % StimN - stimulator number to configure (starts from 1)
        % ChN - channel number to configure (starts from 1)
        % NRep - number of repetitions, can range from 1 to 32767; use 0 for an infinite number of repetitions.
        err = PS_SetRepetitions(StimN, ch, NRep);
            switch err
                case 0
                    disp('Number of pulses set:');
                    disp(NRep);
                otherwise
                    disp('Error setting number of pulses for chosen stimulator');
            end
        
        %Sets repetition rate for a channel in Hertz. Default value is 200 Hz.
        %StimN - stimulator number to configure (starts from 1)
        %ChN - channel number to configure (starts from 1)
        %Rate - rate in Hertz; valid values are from 0.008 Hz <= Rate <= 50000 Hz
        err = PS_SetRate(StimN, ch, Rate);
            switch err
                case 0
                    disp('Frequency set:');
                    disp(Rate);
                otherwise
                    disp('Error setting frequency for chosen stimulator');
            end
        
        % Sets parameters of the rectangular pulse for a channel.
        % StimN - stimulator number to configure (starts from 1)
        % ChN - channel number to configure (starts from 1)
        % Param - array 1x5 containing parameters of the rectangular pulse; it should be defined, for example, as
            % pattern = [100, -100, 25, 25, 25] before calling PS_SetRectParam function.
            % Param [0] is first phase amplitude
            % Param [1] is second phase amplitude
            % Param [2] is first phase width
            % Param [3] is second phase width
            % Param [4] is interphase delay
            % The default values are:
                % - first phase amplitude = 100 mA
                % - second phase amplitude = -100 mA
                % - first phase width = 50 µs
                % - second phase width = 50 µs
                %- interphase delay = 25 µs
        err = PS_SetRectParam(StimN, ch, Param);
            switch err
                case 0
                    disp('Stimulation biphasic pattern parameters have been set');                
                otherwise
                    disp('Error setting biphasic pattern for chosen stimulator');
            end
    end    
    
    % Loads parameters of all channels to the stimulator hardware.
    % StimN - stimulator number (starts from 1)
    err = PS_LoadAllChannels(StimN);
        switch err
            case -1
                disp('Invalid arguments error when loading stimulation parameters for all channels');
            case 1
                disp('Stimulator device error when loading stimulation parameters for all channels');
            case 3
                disp('CRC error when loading stimulation paramters for all channels');
            case 6
                disp('Stimulation pattern(s) is(are) not ready (in case of loading an arbitrary pattern)');
            otherwise
                disp('Stimulation parameters for all channels loaded correctly');
        end
    
    % Starts stimulation for all channels for the stimulator StimN.
    % StimN - stimulator number to configure (starts from 1)
    err = PS_StartStimAllChannels(StimN);
        switch err
            case -1
                disp('Invalid arguments error when starting stimulation for all channels');
            case 1
                disp('Stimulator device error when starting stimulation for all channels');
            case 4
                disp('Wrong trigger mode set when starting stimulation for all channels (trigger mode is not set to PS_TRIG_SOFT (value is 0))');
            otherwise
                disp('Stimulation of all channels executed correctly');
        end

    


% if user wants channels of the same layer to be stimulated
elseif strcmpi(choice,'Layer')==1

    % Set stimulation parameters for each channel in array
    for ch = 1:NCh
        % Sets number of repetitions - the number of times that the bi-phasic pulse or the arbitrary waveform
        % (loaded from a text file) is repeated for channel ChN. Default value is 1.
        % StimN - stimulator number to configure (starts from 1)
        % ChN - channel number to configure (starts from 1)
        % NRep - number of repetitions, can range from 1 to 32767; use 0 for an infinite number of repetitions.
        err = PS_SetRepetitions(StimN, ch, 0);
            switch err
                case 0
                    disp('Number of pulses set: 0');
                otherwise
                    disp('Error setting number of pulses for chosen stimulator');
            end
        
        %Sets repetition rate for a channel in Hertz. Default value is 200 Hz.
        %StimN - stimulator number to configure (starts from 1)
        %ChN - channel number to configure (starts from 1)
        %Rate - rate in Hertz; valid values are from 0.008 Hz <= Rate <= 50000 Hz
        err = PS_SetRate(StimN, ch, 0);
            switch err
                case 0
                    disp('Frequency set: 0');
                otherwise
                    disp('Error setting frequency for chosen stimulator');
            end
        
        % Sets parameters of the rectangular pulse for a channel.
        % StimN - stimulator number to configure (starts from 1)
        % ChN - channel number to configure (starts from 1)
        % Param - array 1x5 containing parameters of the rectangular pulse; it should be defined, for example, as
            % pattern = [100, -100, 25, 25, 25] before calling PS_SetRectParam function.
            % Param [0] is first phase amplitude
            % Param [1] is second phase amplitude
            % Param [2] is first phase width
            % Param [3] is second phase width
            % Param [4] is interphase delay
            % The default values are:
                % - first phase amplitude = 100 mA
                % - second phase amplitude = -100 mA
                % - first phase width = 50 µs
                % - second phase width = 50 µs
                %- interphase delay = 25 µs
        err = PS_SetRectParam(StimN, ch, ParamZero);
            switch err
                case 0
                    disp('Stimulation biphasic pattern parameters have been set');                
                otherwise
                    disp('Error setting biphasic pattern for chosen stimulator');
            end
    end
       
    for w = 1:channelMat(layer,2,1)
        err = PS_SetRepetitions(StimN, channelMat(layer,3,w), NRep);
        switch err
            case 0
                disp('Number of pulses set:');
                disp(NRep);
            otherwise
                disp('Error setting number of pulses for chosen stimulator');
        end

        err = PS_SetRate(StimN, channelMat(layer,3,w), Rate);
        switch err
            case 0
                disp('Frequency set:');
                disp(Rate);
            otherwise
                disp('Error setting frequency for chosen stimulator');
        end

        err = PS_SetRectParam(StimN, channelMat(layer,3,w), Param);
        switch err
            case 0
                disp('Stimulation biphasic pattern parameters have been set');
            otherwise
                disp('Error setting biphasic pattern for chosen stimulator');
        end
    end


   % Loads parameters of all channels to the stimulator hardware.
    % StimN - stimulator number (starts from 1)
    err = PS_LoadAllChannels(StimN);
        switch err
            case -1
                disp('Invalid arguments error when loading stimulation parameters for all channels');
            case 1
                disp('Stimulator device error when loading stimulation parameters for all channels');
            case 3
                disp('CRC error when loading stimulation paramters for all channels');
            case 6
                disp('Stimulation pattern(s) is(are) not ready (in case of loading an arbitrary pattern)');
            otherwise
                disp('Stimulation parameters for all channels loaded correctly');
        end
    
    % Starts stimulation for all channels for the stimulator StimN.
    % StimN - stimulator number to configure (starts from 1)
    err = PS_StartStimAllChannels(StimN);
        switch err
            case -1
                disp('Invalid arguments error when starting stimulation for all channels');
            case 1
                disp('Stimulator device error when starting stimulation for all channels');
            case 4
                disp('Wrong trigger mode set when starting stimulation for all channels (trigger mode is not set to PS_TRIG_SOFT (value is 0))');
            otherwise
                disp('Stimulation of all channels executed correctly');
        end



% if user wants a single channel to be stimulated
else
    
    % Sets number of repetitions - the number of times that the bi-phasic pulse or the arbitrary waveform
    % (loaded from a text file) is repeated for channel ChN. Default value is 1.
    % StimN - stimulator number to configure (starts from 1)
    % ChN - channel number to configure (starts from 1)
    % NRep - number of repetitions, can range from 1 to 32767; use 0 for an infinite number of repetitions.
    err = PS_SetRepetitions(StimN, ChN, NRep);
        switch err
            case 0
                disp('Number of pulses set:');
                disp(NRep);
            otherwise
                disp('Error setting number of pulses for chosen stimulator');
        end
   
    %Sets repetition rate for a channel in Hertz. Default value is 200 Hz.
    %StimN - stimulator number to configure (starts from 1)
    %ChN - channel number to configure (starts from 1)
    %Rate - rate in Hertz; valid values are from 0.008 Hz <= Rate <= 50000 Hz    
    err = PS_SetRate(StimN, ChN, Rate);
        switch err
            case 0
                disp('Frequency set:');
                disp(Rate);
            otherwise
                disp('Error setting frequency for chosen stimulator');
        end

    % Sets parameters of the rectangular pulse for a channel.
    % StimN - stimulator number to configure (starts from 1)
    % ChN - channel number to configure (starts from 1)
    % Param - array 1x5 containing parameters of the rectangular pulse; it should be defined, for example, as
        % pattern = [100, -100, 25, 25, 25] before calling PS_SetRectParam function.
        % Param [0] is first phase amplitude
        % Param [1] is second phase amplitude
        % Param [2] is first phase width
        % Param [3] is second phase width
        % Param [4] is interphase delay
        % The default values are:
            % - first phase amplitude = 100 mA
            % - second phase amplitude = -100 mA
            % - first phase width = 50 µs
            % - second phase width = 50 µs
            %- interphase delay = 25 µs
    err = PS_SetRectParam(StimN, ChN, Param);
        switch err
            case 0
                disp('Stimulation biphasic pattern parameters have been set');                
            otherwise
                disp('Error setting biphasic pattern for chosen stimulator');
        end  
    
    % Loads parameters of the selected channel to the stimulator hardware.
    % StimN - stimulator number (starts from 1)
    % ChN - channel number which parameters will be loaded in the stimulator hardware (starts from 1)
     err = PS_LoadChannel(StimN, ChN);   
        switch err
            case -1
                disp('Invalid arguments error when loading stimulation parameters for the selected channel');
            case 1
                disp('Stimulator device error when loading stimulation parameters for the selected channel');
            case 3
                disp('CRC error when loading stimulation paramters for the selected channel');
            case 6
                disp('Stimulation pattern(s) is(are) not ready (in case of loading an arbitrary pattern)');
            otherwise
                disp('Stimulation parameters for the selected channel loaded correctly');
        end

    % Starts stimulation the selected channel for the stimulator StimN.
    % StimN - stimulator number to configure (starts from 1)
    % ChN - channel number which parameters will be loaded in the stimulator hardware (starts from 1)    
    err = PS_StartStimChannel(StimN, ChN);
        switch err
            case -1
                disp('Invalid arguments error when starting stimulation for the selected channel');
            case 1
                disp('Stimulator device error when starting stimulation for the selected channel');
            case 4    
                disp('Wrong trigger mode set when starting stimulation for the selected channel (trigger mode is not set to PS_TRIG_SOFT (value is 0))');
            otherwise
                disp('Stimulation of the selected channel executed correctly');
        end
end

% Acquire data from oscilloscope
%fprintf('Capturing waveform...\n');
% Query for waveform data
fprintf(v,'DATA:SOURCE CH1');
fprintf(v,'CURVe?');
% Acquire waveform data
wf_v = str2num(fscanf(v));
% Acquire constants to convert digitized data to appropriate voltage
fprintf(v,'WFMPre:YZEro?');
yzero_v = str2num(fscanf(v));
fprintf(v,'WFMPre:YMUlt?');
ymulty_v = str2num(fscanf(v));
fprintf(v,'WFMPre:YOFf?');
yoff_v = str2num(fscanf(v));
% Convert digitized waveform to voltage (oscilloscope displays 250
% mV per 1 V actual, only if using the voltage output from the stimulator)
vtrans = (yzero_v + ymulty_v * (wf_v - yoff_v)) * 4;
% Get time vector
fprintf(v, 'WFMPre:XINcr?');
Interval = str2num(fscanf(v));
Time = linspace(0, Interval * length(vtrans), length(vtrans))*1000000;
%save(Time);

% Saving vtrans plots
f1 = figure;
plot(Time,vtrans);
title('Square Wave Plot');
xlabel('Time (us)');
ylabel('Volts (V)');
grid on;
set(f1,'visible','off');
if trial == 1
    folderName = string(['StimDataOutput\' datestr(date) '_' exp_name '_Attempt#' num2str(attempt)]);
    mkdir(folderName);
end
saveas(gcf, ['StimDataOutput\' datestr(date) '_' exp_name '_Attempt#' num2str(attempt) '\Channel-' num2str(ChN) '_Trial-' num2str(trial) '_SquaredWaveformVoltageTransientData' '.png']);
save(['StimDataOutput\' datestr(date) '_' exp_name '_Attempt#' num2str(attempt) '\Channel-' num2str(ChN) '_Trial-' num2str(trial) '_SquaredWaveformVoltageTransientData'], 'vtrans');
close(f1);


% Finalizes work with all available stimulators. Any stimulation in progress is aborted.
err = PS_CloseAllStim();
    switch err
        case 1
            disp('Error closing all stimulators');
        otherwise
            disp('All stimulators closed correctly');
    end


end