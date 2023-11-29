frequency = 6000;
duration = 1;
amplitude = 1;

% set auditory parameters to be within range of human hearing
 samplingRate = 40000;
 sampledTimeArray = 0:1/samplingRate:duration;
 waveform=sin(2*pi*frequency*sampledTimeArray);

 % play auditory tone to user
 sound(amplitude*waveform,samplingRate);


 duration = 1;
 amplitude = 100;

 samplingFrequency = 6000;
 numberOfSamples = 1:samplingFrequency*duration;
 tone = sin(numberOfSamples).*amplitude;
 tone(1:samplingFrequency) = tone(1:samplingFrequency).*(1/samplingFrequency:1/samplingFrequency:1);
 tone(end-samplingFrequency+1:end) = tone(end-samplingFrequency+1:end).*fliplr((1/samplingFrequency:1/samplingFrequency:1));
 
 