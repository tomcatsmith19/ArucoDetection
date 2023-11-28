%% Parameters
% Variable parameters
ch = 10; % Need to resolder/fix channels to make sure that each are correct
% solder omnetics connector directly to commutator
charge = 5; % nC (new starting charge value because 30 would take us too high)
% max is now 15 nC
% min is still 0.5 nC

% Fixed parameters
npulses = 208;
freq = 320; % Hz
width = 200; % us
delay = 40; % us

amplitude = round(charge*1000/width); % uA

%% Setup oscilloscope
% Establish connection with oscilloscope
fprintf('Connecting to oscilloscope...\n');
% Instrument Connection

% Find a VISA-USB object using Open Choice Instrument Manager
v = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x0699::0x0368::C017166::0::INSTR', 'Tag', '');

% Create the VISA-USB object if it does not exist
% otherwise use the object that was found.
if isempty(v)
    v = visa('tek', 'USB0::0x0699::0x0368::C017166::0::INSTR');
else
    fclose(v);
    v = v(1);
end
v.InputBufferSize = 100000;
% Connect to instrument object, obj1.
fopen(v);
fprintf('Connected to oscilloscope...\n');
% Ensure ASCII encoding so the data output makes sensein
fprintf(v,'DATA:ENC ASCI');
fprintf(v, 'ACQuire:MODe SAMple');

%% Setup stimulator
res = PS_InitAllStim;
[NStim, err] = PS_GetNStim;
[NChan, err] = PS_GetNChannels(1);

res = PS_SetMonitorChannel(1, ch);
PS_SetRepetitions(1, ch, npulses);
PS_SetRate(1,ch,freq);

%check parameters for the rectangular pulse
[Values, err] = PS_GetRectParam(1, 1);

%set new parameters for the rectangular pulse
pattern = [-1*amplitude, amplitude, width, width, delay];
PS_SetRectParam(1, ch, pattern);

%check if new parameters for the rectangular pulse has been set up
Values = PS_GetRectParam(1, ch);

err = PS_LoadChannel(1,ch);
err = PS_StartStimChannel(1,ch);

%% Acquire data from oscilloscope
        fprintf('Capturing waveform...\n');
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
        interval = str2num(fscanf(v));
        time = linspace(0, interval * length(vtrans), length(vtrans));

        
%% Plots
% plot(vtrans)
% cannot do current also because the stimulation is so short that it doesnt
% have enough time to record both.


%% Close stimulator
err = PS_CloseStim(1);
