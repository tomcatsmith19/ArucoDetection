function tonePresentation(amplitude, frequency, duration, samplefreq, rampDuration)

% amplitude = .1;
% frequency = 6000;
% duration = .5;
% samplefreq = 100000;
% rampDuration = .2;

% .1 Amp = -20dB
% .01 Amp = -40dB
% .001 Amp = -60dB
   
numOfSamplesInDuration = linspace(0,duration, duration*samplefreq);
tone = amplitude*sin(frequency*2*pi*numOfSamplesInDuration);

NumOfSamplesInRamp = length(numOfSamplesInDuration)*rampDuration;
tone(1:NumOfSamplesInRamp) = tone(1:NumOfSamplesInRamp).*((1/NumOfSamplesInRamp:1/NumOfSamplesInRamp:1));
tone(end-NumOfSamplesInRamp+1:end) = tone(end-NumOfSamplesInRamp+1:end).*fliplr((1/NumOfSamplesInRamp:1/NumOfSamplesInRamp:1));

%plot(tone);
% title('Auditory Tone Presentation');
% xlabel();
% ylabel('Amplitude');
%set(gca,'visible','off')
%set(gcf,'color','w');


sound(tone,samplefreq);

end